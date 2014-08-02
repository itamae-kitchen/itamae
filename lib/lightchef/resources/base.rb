require 'lightchef'
require 'shellwords'

module Lightchef
  module Resources
    class Base
      class << self
        attr_reader :defined_options

        def define_option(name, options)
          @defined_options ||= {
            action: {type: Symbol, required: true}
          }

          current = @defined_options[name.to_sym] || {}
          @defined_options[name.to_sym] = current.merge(options)
        end
      end

      attr_reader :resource_name
      attr_reader :options

      def initialize(recipe, resource_name, &block)
        @options = {}
        @recipe = recipe
        @resource_name = resource_name

        instance_eval(&block) if block_given?

        process_options
      end

      def run
        public_send("#{action}_action".to_sym)
      end

      private

      def method_missing(method, *args)
        if args.size == 1 && self.class.defined_options[method]
          return @options[method] = args.first
        elsif args.size == 0 && @options.has_key?(method)
          return @options[method]
        end
        super
      end

      def process_options
        self.class.defined_options.each_pair do |key, details|
          @options[key] ||= @resource_name if details[:default_name]
          @options[key] ||= details[:default]

          if details[:required] && !@options[key]
            raise Resources::OptionMissingError, "'#{key}' option is required but it is not set."
          end

          if @options[key] && details[:type] && !@options[key].is_a?(details[:type])
            raise Resources::InvalidTypeError, "#{key} option should be #{details[:type]}."
          end
        end
      end

      def run_specinfra(type, *args)
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

