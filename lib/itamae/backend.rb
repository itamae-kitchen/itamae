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
          command = "sudo -u #{Shellwords.escape(user)} -- /bin/sh -c #{Shellwords.escape(command)}"
        end

        Logger.debug "Executing `#{command}`..."

        result = @backend.run_command(command)
        exit_status = result.exit_status

        Logger.formatter.with_indent do
          if exit_status == 0 || !options[:error]
            method = :debug
            message = "exited with #{exit_status}"
          else
            method = :error
            message = "Command `#{command}` failed. (exit status: #{exit_status})"
          end

          Logger.public_send(method, message)

          {"stdout" => result.stdout, "stderr" => result.stderr}.each_pair do |name, value|
            next unless value && value != ''

            if value.bytesize > 1024 * 1024
              Logger.public_send(method, "#{name} is suppressed because it's too large")
              next
            end

            value.each_line do |line|
              # remove control chars
              case line.encoding
              when Encoding::UTF_8
                line = line.tr("\u0000-\u001f\u007f\u2028",'')
              end

              Logger.public_send(method, "#{name} | #{line}")
            end
          end
        end

        if options[:error] && exit_status != 0
          raise CommandExecutionError
        end

        result
      end

      def get_command(*args)
        @backend.command.get(*args)
      end

      def send_file(*args)
        @backend.send_file(*args)
      end

      def send_directory(*args)
        @backend.send_directory(*args)
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
          disable_sudo: ssh_options[:disable_sudo],
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
        opts[:disable_sudo] = true unless @options[:sudo]

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
