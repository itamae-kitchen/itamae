require 'itamae'

module Itamae
  class Runner
    CommandExecutionError = Class.new(StandardError)

    class << self
      def run(recipe_files, backend, options)
        backend = backend_from_options(backend, options)

        runner = self.new(node_from_options(options))

        recipe_files.each do |path|
          recipe = Recipe.new(runner, File.expand_path(path))
          recipe.run(dry_run: options[:dry_run])
        end
      end

      private
      def node_from_options(options)
        if options[:node_json]
          path = File.expand_path(options[:node_json])
          Logger.debug "Loading node data from #{path} ..."
          hash = JSON.load(open(path))
        else
          hash = {}
        end

        Node.new(hash)
      end

      def backend_from_options(type, options)
        case type
        when :local
          Itamae.create_local_backend
        when :ssh
          ssh_options = {}
          ssh_options[:host] = options[:host]
          ssh_options[:user] = options[:user] || Etc.getlogin
          ssh_options[:keys] = [options[:key]] if options[:key]
          ssh_options[:port] = options[:port] if options[:port]

          Itamae.create_ssh_backend(ssh_options)
        end
      end
    end

    attr_accessor :node

    def initialize(node)
      @node = node
    end

    def run_specinfra(type, *args)
      command = Specinfra.command.get(type, *args)

      if type.to_s.start_with?("check_")
        result = run_command(command, error: false)
        result.exit_status == 0
      else
        run_command(command)
      end
    end

    def run_command(command, options = {})
      options = {error: true}.merge(options)

      result = Itamae.backend.run_command(command)
      exit_status = result.exit_status

      if exit_status == 0 || !options[:error]
        method = :debug
        message = "  Command `#{command}` exited with #{exit_status}"
      else
        method = :error
        message = "  Command `#{command}` failed. (exit status: #{exit_status})"
      end

      Logger.public_send(method, message)

      {"stdout" => result.stdout, "stderr" => result.stderr}.each_pair do |name, value|
        if value && value != ''
          value.each_line do |line|
            # remove control chars
            line = line.tr("\u0000-\u001f\u007f\u2028",'')
            Logger.public_send(method, "    #{name} | #{line}")
          end
        end
      end

      if options[:error] && exit_status != 0
        raise CommandExecutionError
      end

      result
    end
  end
end

