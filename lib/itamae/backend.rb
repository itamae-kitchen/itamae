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
      attr_reader :executed_commands

      def initialize(options)
        @options = options
        @backend = create_specinfra_backend
        @executed_commands = []
      end

      def run_command(commands, options = {})
        options = {error: true}.merge(options)

        command = build_command(commands, options)
        Itamae.logger.debug "Executing `#{command}`..."

        result = nil

        Itamae.logger.with_indent do
          reset_output_handler

          result = run_command_with_profiling(command)

          flush_output_handler_buffer

          if result.exit_status == 0 || !options[:error]
            method = :debug
            message = "exited with #{result.exit_status}"
          else
            method = :error
            message = "Command `#{command}` failed. (exit status: #{result.exit_status})"

            unless Itamae.logger.level == ::Logger::DEBUG
              result.stdout.each_line do |l|
                log_output_line("stdout", l, :error)
              end
              result.stderr.each_line do |l|
                log_output_line("stderr", l, :error)
              end
            end
          end

          Itamae.logger.public_send(method, message)
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
          Itamae.logger.debug "Receiving a file from '#{src}' to '#{dst}'..."
        else
          Itamae.logger.debug "Receiving a file from '#{src}'..."
        end
        @backend.receive_file(src, dst)
      end

      def send_file(src, dst)
        Itamae.logger.debug "Sending a file from '#{src}' to '#{dst}'..."
        unless ::File.exist?(src)
          raise SourceNotExistError, "The file '#{src}' doesn't exist."
        end
        unless ::File.file?(src)
          raise SourceNotExistError, "'#{src}' is not a file."
        end
        @backend.send_file(src, dst)
      end

      def send_directory(src, dst)
        Itamae.logger.debug "Sending a directory from '#{src}' to '#{dst}'..."
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
        Itamae.logger.public_send(severity, "#{output_name} | #{line}")
      end

      def build_command(commands, options)
        if commands.is_a?(Array)
          command = commands.map do |cmd|
            cmd.shellescape
          end.join(' ')
        else
          command = commands
        end

        cwd = options[:cwd]
        if cwd
          command = "cd #{cwd.shellescape} && #{command}"
        end

        user = options[:user]
        if user
          command = "cd ~#{user.shellescape} ; #{command}"
          command = "sudo -H -u #{user.shellescape} -- #{shell.shellescape} -c #{command.shellescape}"
        end

        command
      end

      def shell
        @options[:shell] || '/bin/sh'
      end

      def run_command_with_profiling(command)
        start_at = Time.now
        result = @backend.run_command(command)
        duration = Time.now.to_f - start_at.to_f

        @executed_commands << {command: command, duration: duration}

        result
      end
    end

    class Local < Base
      private
      def create_specinfra_backend
        Specinfra::Backend::Exec.new(
          shell: @options[:shell],
        )
      end
    end

    class Jexec < Base
      private
      def create_specinfra_backend
        Specinfra::Backend::Jexec.new(
          shell: @options[:shell],
          login_shell: @options[:login_shell],
          jail_name: @options[:jail_name],
        )
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
          shell: @options[:shell],
          login_shell: @options[:login_shell],
        )
      end

      def ssh_options
        opts = {}

        opts[:host_name] = @options[:host]

        # from ssh-config
        ssh_config_files = @options[:ssh_config] ? [@options[:ssh_config]] : Net::SSH::Config.default_files
        opts.merge!(Net::SSH::Config.for(@options[:host], ssh_config_files))
        opts[:user] = @options[:user] || opts[:user] || Etc.getlogin
        opts[:password] = @options[:password] if @options[:password]
        opts[:keys] = [@options[:key]] if @options[:key]
        opts[:port] = @options[:port] if @options[:port]

        if @options[:vagrant]
          config = Tempfile.new('', Dir.tmpdir)
          hostname = opts[:host_name] || 'default'
          vagrant_cmd = "vagrant ssh-config #{hostname} > #{config.path}"
          if defined?(Bundler)
            Bundler.with_clean_env do
              `#{vagrant_cmd}`
            end
          else
            `#{vagrant_cmd}`
          end
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
        /\A(?<repo>.+?)(?:|:(?<tag>[^:]+))\z/.match(@options[:tag]) do |m|
          image.tag(repo: m[:repo], tag: m[:tag])
        end
        Itamae.logger.info "Image created: #{image.id}"
      end

      private
      def create_specinfra_backend
        begin
          require 'docker'
        rescue LoadError
          Itamae.logger.fatal "To use docker backend, please install 'docker-api' gem"
        end

        # TODO: Move to Specinfra?
        Excon.defaults[:ssl_verify_peer] = @options[:tls_verify_peer]
        ::Docker.logger = Itamae.logger

        Specinfra::Backend::Docker.new(
          docker_image: @options[:image],
          docker_container: @options[:container],
          shell: @options[:shell],
          docker_container_create_options: @options[:docker_container_create_options],
        )
      end
    end
  end
end
