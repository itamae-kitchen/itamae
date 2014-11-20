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
  class Backend
    UnknownBackendTypeError = Class.new(StandardError)
    CommandExecutionError = Class.new(StandardError)

    include Singleton

    def set_type(type, options = {})
      case type
      when :local
        Specinfra.configuration.backend = :exec
      when :ssh
        Specinfra.configuration.request_pty = true
        Specinfra.configuration.host = options.delete(:host)
        Specinfra.configuration.disable_sudo = options.delete(:disable_sudo)
        Specinfra.configuration.ssh_options = options

        Specinfra.configuration.backend = :ssh
      else
        raise UnknownBackendTypeError, "'#{type}' backend is unknown."
      end
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
        command = "sudo -u #{Shellwords.escape(user)} -- /bin/sh -c #{Shellwords.escape(command)}"
      end
      command
    end

    def build_log(command, options, result)
      exit_status = result.exit_status

      Logger.formatter.indent do
        if result.exit_status == 0 || !options[:error]
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
    end

    def check_command(commands, options = {})
      options[:error] = false
      command = build_command(commands, options)

      Logger.debug "Executing `#{command}`..."

      result = Specinfra::Runner.run_command(command)

      build_log(command, options, result)

      result
    end

    def run_command(commands, options = {})
      options = {error: true}.merge(options)

      command = build_command(commands, options)

      Logger.debug "Executing `#{command}`..."

      result = Specinfra::Runner.run_command(command)

      build_log(command, options, result)

      if options[:error] && result.exit_status != 0
        raise CommandExecutionError
      end

      result
    end

    def run_specinfra(type, *args)
      command = Specinfra.command.get(type, *args)

      if type.to_s.start_with?("check_")
        result = check_command(command)
        result.exit_status == 0
      else
        run_command(command)
      end
    end

    def send_file(*args)
      Specinfra::Runner.send_file(*args)
    end
  end
end
