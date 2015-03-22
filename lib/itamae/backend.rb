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
      when :dockerfile
        Specinfra.configuration.backend = :dockerfile
        Specinfra.configuration.os = {family: options[:family]}
        @output_dir = options[:output_dir]
        unless @output_dir.nil?
          FileUtils.mkdir_p("#{@output_dir}/sub_script")
          Specinfra.configuration.dockerfile_finalizer =
            proc { |lines|
              new_lines = []
              sub_script_num = 0
              straight_run = []
              lines.each do |line|
                if line.match(/^RUN /)
                  straight_run << line.sub(/^RUN /, '')
                elsif !straight_run.empty?
                  sub_script_path = "sub_script/#{"%03d" % sub_script_num}.sh"
                  open("#{@output_dir}/#{sub_script_path}", 'w') do |f|
                    f.write(straight_run.join("\n"))
                  end
                  sub_script_num += 1
                  straight_run.clear
                  new_lines << "RUN sh #{sub_script_path}"
                  new_lines << line
                else
                  new_lines << line
                end
              end
              open("#{@output_dir}/Dockerfile", 'w') { |f|
                f.write(new_lines.join("\n"))
              }
            }
        end
      else
        raise UnknownBackendTypeError, "'#{type}' backend is unknown."
      end
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
      case Specinfra.configuration.backend
      when :dockerfile
        if @output_dir.nil?
          Specinfra::Runner.send_file(*args)
        else
          src = args[0]
          dst = args[1]
          if dst.start_with?('/')
            new_src = "_root_#{dst}"
          else
            new_src = dst
          end
          real_new_src = "#{@output_dir}/#{new_src}"
          FileUtils.mkdir_p(File::dirname(real_new_src))
          FileUtils.cp_r(src, real_new_src)
          args[0] = new_src
          Specinfra::Runner.send_file(*args)
        end
      else
        Specinfra::Runner.send_file(*args)
      end
    end

    def send_directory(*args)
      Specinfra::Runner.send_directory(*args)
    end
  end
end
