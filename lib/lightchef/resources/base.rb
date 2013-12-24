require 'lightchef'

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

      def run_command(type, *args)
        command = backend.commands.public_send(type, *args)
        result = backend.run_command(command)
        exit_status = result[:exit_status]
        if exit_status == 0
          Logger.debug "Command `#{command}` succeeded"
          Logger.debug "STDOUT> #{(result[:stdout] || "").chomp}"
          Logger.debug "STDERR> #{(result[:stderr] || "").chomp}"
        else
          Logger.error "Command `#{command}` failed. (exit status: #{exit_status})"
          Logger.error "STDOUT> #{(result[:stdout] || "").chomp}"
          Logger.error "STDERR> #{(result[:stderr] || "").chomp}"
          raise CommandExecutionError
        end
      end

      def copy_file(src, dst)
        Logger.debug "Copying a file from '#{src}' to '#{dst}'..."
        backend.copy_file(src, dst)
      end

      def node
        current_runner.node
      end

      private
      def backend
        current_runner.backend
      end

      def current_runner
        @recipe.current_runner
      end
    end
  end
end

