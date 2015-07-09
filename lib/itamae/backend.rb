require 'specinfra/core'
require 'singleton'
require 'io/console'
require 'net/ssh'

Specinfra::Configuration.error_on_missing_backend_type = true

module Specinfra
  module Configuration
    def self.sudo_password
      return ENV['SUDO_PASSWORD'] if ENV['SUDO_PASSWORD']
      return @sudo_password if @sudo_password

      # TODO: Fix this dirty hack
      return nil unless caller.any? {|call| call.include?('channel_data') }

      print "sudo password: "
      @sudo_password = STDIN.noecho(&:gets).strip
      print "\n"
      @sudo_password
    end
  end
end

module Itamae
  module Backend
    UnknownBackendTypeError = Class.new(StandardError)
    CommandExecutionError = Class.new(StandardError)
    SourceNotExistError = Class.new(StandardError)

    class << self
      def create(type, opts = {})
        self.const_get(type.capitalize).new(opts)
      end
    end

    class Base
      def initialize(options)
        @options = options
        @backend = create_specinfra_backend
      end

      def run_command(commands, options = {})
        options = {error: true}.merge(options)

        command = build_command(commands, options)
        Logger.debug "Executing `#{command}`..."

        result = nil

        Logger.formatter.with_indent do
          reset_output_handler
          result = @backend.run_command(command)
          flush_output_handler_buffer

          if result.exit_status == 0 || !options[:error]
            method = :debug
            message = "exited with #{result.exit_status}"
          else
            method = :error
            message = "Command `#{command}` failed. (exit status: #{result.exit_status})"

            unless Logger.logger.level == ::Logger::DEBUG
              result.stdout.each_line do |l|
                log_output_line("stdout", l, :error)
              end
              result.stderr.each_line do |l|
                log_output_line("stderr", l, :error)
              end
            end
          end

          Logger.public_send(method, message)
        end

        if options[:error] && result.exit_status != 0
          raise CommandExecutionError
        end

        result
      end

      def get_command(*args)
        @backend.command.get(*args)
      end

      def receive_file(src, dst = nil)
        if dst
          Logger.debug "Receiving a file from '#{src}' to '#{dst}'..."
        else
          Logger.debug "Receiving a file from '#{src}'..."
        end
        @backend.receive_file(src, dst)
      end

      def send_file(src, dst)
        Logger.debug "Sending a file from '#{src}' to '#{dst}'..."
        unless ::File.exist?(src)
          raise SourceNotExistError, "The file '#{src}' doesn't exist."
        end
        unless ::File.file?(src)
          raise SourceNotExistError, "'#{src}' is not a file."
        end
        @backend.send_file(src, dst)
      end

      def send_directory(src, dst)
        Logger.debug "Sending a directory from '#{src}' to '#{dst}'..."
        unless ::File.exist?(src)
          raise SourceNotExistError, "The directory '#{src}' doesn't exist."
        end
        unless ::File.directory?(src)
          raise SourceNotExistError, "'#{src}' is not a directory."
        end
        @backend.send_directory(src, dst)
      end

      def host_inventory
        @backend.host_inventory
      end

      def finalize
        # pass
      end

      private

      def create_specinfra_backend
        raise NotImplementedError
      end

      def reset_output_handler
        @buf = {}
        %w!stdout stderr!.each do |output_name|
          @buf[output_name] = ""
          handler = lambda do |str|
            lines = str.split(/\r?\n/, -1)
            @buf[output_name] += lines.pop
            unless lines.empty?
              lines[0] = @buf[output_name] + lines[0]
              @buf[output_name] = ""
              lines.each do |l|
                log_output_line(output_name, l)
              end
            end
          end
          @backend.public_send("#{output_name}_handler=", handler)
        end
      end

      def flush_output_handler_buffer
        @buf.each do |output_name, line|
          next if line.empty?
          log_output_line(output_name, line)
        end
      end

      def log_output_line(output_name, line, severity = :debug)
        line = line.gsub(/[[:cntrl:]]/, '')
        Logger.public_send(severity, "#{output_name} | #{line}")
      end

      def build_command(commands, options)
        if commands.is_a?(Array)
          command = commands.map do |cmd|
            Shellwords.escape(cmd)
          end.join(' ')
        else
          command = commands
        end

        cwd = options[:cwd]
        if cwd
          command = "cd #{Shellwords.escape(cwd)} && #{command}"
        end

        user = options[:user]
        if user
          command = "sudo -H -u #{Shellwords.escape(user)} -- /bin/sh -c #{Shellwords.escape(command)}"
        end

        command
      end
    end

    # TODO: Make Specinfra's backends instanciatable 
    class Local < Base
      private
      def create_specinfra_backend
        Specinfra::Backend::Exec.new()
      end
    end

    class Ssh < Base
      private
      def create_specinfra_backend
        Specinfra::Backend::Ssh.new(
          request_pty: true,
          host: ssh_options[:host_name],
          disable_sudo: disable_sudo?,
          ssh_options: ssh_options,
        )
      end

      def ssh_options
        opts = {}

        opts[:host_name] = @options[:host]

        # from ssh-config
        opts.merge!(Net::SSH::Config.for(@options[:host]))
        opts[:user] = @options[:user] || opts[:user] || Etc.getlogin
        opts[:keys] = [@options[:key]] if @options[:key]
        opts[:port] = @options[:port] if @options[:port]

        if @options[:vagrant]
          config = Tempfile.new('', Dir.tmpdir)
          hostname = opts[:host_name] || 'default'
          `vagrant ssh-config #{hostname} > #{config.path}`
          opts.merge!(Net::SSH::Config.for(hostname, [config.path]))
        end

        if @options[:ask_password]
          print "password: "
          password = STDIN.noecho(&:gets).strip
          print "\n"
          opts.merge!(password: password)
        end

        opts
      end

      def disable_sudo?
        !@options[:sudo]
      end
    end

    class Docker < Base
      def finalize
        image = @backend.commit_container
        Logger.info "Image created: #{image.id}"
      end

      private
      def create_specinfra_backend
        begin
          require 'docker'
        rescue LoadError
          Logger.fatal "To use docker backend, please install 'docker-api' gem"
        end

        # TODO: Move to Specinfra?
        Excon.defaults[:ssl_verify_peer] = @options[:tls_verify_peer]
        ::Docker.logger = Logger

        Specinfra::Backend::Docker.new(
          docker_image: @options[:image],
          docker_container: @options[:container],
        )
      end
    end
  end
end
