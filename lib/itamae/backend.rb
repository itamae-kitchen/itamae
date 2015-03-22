require 'specinfra'
require 'singleton'
require 'io/console'

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
      def set_type(type, opts = {})
        @instance = self.const_get(type.capitalize).new(opts)
      end

      def instance
        unless @instance
          raise "Before calling Backend.instance, call Backend.set_type."
        end

        @instance
      end
    end

    class Base
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

        result = Specinfra::Runner.run_command(command)
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
        Specinfra.command.get(*args)
      end

      def send_file(*args)
        Specinfra::Runner.send_file(*args)
      end

      def send_directory(*args)
        Specinfra::Runner.send_directory(*args)
      end

      def finalize
        # pass
      end
    end

    # TODO: Make Specinfra's backends instanciatable 
    class Local < Base
      def initialize(options)
        Specinfra.configuration.backend = :exec
      end
    end

    class Ssh < Base
      def initialize(options)
        Specinfra.configuration.request_pty = true
        Specinfra.configuration.host = options.delete(:host)
        Specinfra.configuration.disable_sudo = options.delete(:disable_sudo)
        Specinfra.configuration.ssh_options = options

        Specinfra.configuration.backend = :ssh
      end
    end

    class Docker < Base
      def initialize(options)
        begin
          require 'docker'
        rescue LoadError
          Logger.fatal "To use docker backend, please install 'docker-api' gem"
        end

        Specinfra.configuration.docker_image = options[:image]
        Specinfra.configuration.docker_container = options[:container]

        # TODO: Move to Specinfra?
        Excon.defaults[:ssl_verify_peer] = options[:tls_verify_peer]

        Specinfra.configuration.backend = :docker

        ::Docker.logger = Logger
      end

      def finalize
        image = Specinfra.backend.commit_container
        Logger.info "Image created: #{image.id}"
      end
    end
  end
end
