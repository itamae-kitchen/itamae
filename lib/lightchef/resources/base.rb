require 'lightchef'
require 'shellwords'

module Lightchef
  module Resources
    class Base
      attr_reader :options

      def initialize(recipe, name, &block)
        @options = {}
        @recipe = recipe
        instance_eval(&block) if block_given?
      end

      def run
        action = fetch_option(:action)
        public_send("#{action}_action".to_sym)
      end

      def fetch_option(key)
        @options.fetch(key) do |k|
          raise Error, "#{k} is not specified."
        end
      end

      def method_missing(method, *args)
        if args.size == 1
          @options[method] = args.first
          return
        end
        super
      end

      def run_specinfra_command(type, *args)
        command = backend.commands.public_send(type, *args)
        run_command(command)
      end

      def run_command(command)
        result = backend.run_command(command)
        exit_status = result.exit_status

        if exit_status == 0
          method = :debug
          Logger.public_send(method, "Command `#{command}` succeeded")
        else
          method = :error
          Logger.public_send(method, "Command `#{command}` failed. (exit status: #{exit_status})")
        end

        if result.stdout && result.stdout != ''
          Logger.public_send(method, "STDOUT> #{result.stdout.chomp}")
        end
        if result.stderr && result.stderr != ''
          Logger.public_send(method, "STDERR> #{result.stderr.chomp}")
        end

        unless exit_status == 0
          raise CommandExecutionError
        end
      end

      def copy_file(src, dst)
        Logger.debug "Copying a file from '#{src}' to '#{dst}'..."
        backend.copy_file(src, dst)
      end

      def node
        runner.node
      end

      private
      def backend
        runner.backend
      end

      def runner
        @recipe.runner
      end

      def shell_escape(str)
        Shellwords.escape(str)
      end
    end
  end
end

