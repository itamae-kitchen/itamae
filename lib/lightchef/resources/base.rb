require 'lightchef'

module Lightchef
  module Resources
    Error = Class.new(StandardError)
    CommandExecutionError = Class.new(StandardError)

    class Base
      attr_reader :options

      def initialize(recipe, *args, &block)
        @options = {}
        @recipe = recipe
        instance_eval(&block)
      end

      def run
        action = fetch_option(:action)
        public_send("#{action}_action".to_sym)
      end

      def fetch_option(key)
        value = @options[key]
        raise Error, "#{key} is not specified." unless value
        value
      end

      def method_missing(method, *args)
        if args.size == 1
          @options[method] = args.first
          return
        end
        super
      end

      private
      def run_command(type, *args)
        command = @recipe.backend.commands.public_send(type, *args)
        result = @recipe.backend.run_command(command)
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
        @recipe.backend.copy_file(src, dst)
      end
    end
  end
end

