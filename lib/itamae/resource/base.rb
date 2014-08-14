require 'itamae'
require 'shellwords'

module Itamae
  module Resource
    class Base
      @defined_attributes ||= {}
      @supported_oses ||= []

      class << self
        attr_reader :defined_attributes
        attr_reader :supported_oses

        def inherited(subclass)
          subclass.instance_variable_set(
            :@defined_attributes,
            self.defined_attributes.dup
          )
        end

        def define_attribute(name, options)
          current = @defined_attributes[name.to_sym] || {}
          @defined_attributes[name.to_sym] = current.merge(options)
        end

        def support_os(hash)
          @supported_oses << hash
        end
      end

      define_attribute :action, type: Symbol, required: true

      attr_reader :resource_name
      attr_reader :attributes
      attr_reader :current_attributes

      def initialize(recipe, resource_name, &block)
        @attributes = {}
        @current_attributes = {}
        @recipe = recipe
        @resource_name = resource_name

        instance_eval(&block) if block_given?

        process_attributes
        ensure_os
      end

      def run
        if do_not_run_because_of_only_if?
          Logger.info "Execution skipped because of only_if attribute"
          return
        elsif do_not_run_because_of_not_if?
          Logger.info "Execution skipped because of not_if attribute"
          return
        end

        set_current_attributes
        show_differences

        public_send("#{action}_action".to_sym)
      end

      def nothing_action
        # do nothing
      end

      private

      def method_missing(method, *args)
        if args.size == 1 && self.class.defined_attributes[method]
          return @attributes[method] = args.first
        elsif args.size == 0 && @attributes.has_key?(method)
          return @attributes[method]
        end
        super
      end

      def set_current_attributes
      end

      def show_differences
        @current_attributes.each_pair do |key, current_value|
          value = @attributes[key]
          Logger.info "  #{key}: #{current_value} -> #{value}"
        end
      end

      def process_attributes
        self.class.defined_attributes.each_pair do |key, details|
          @attributes[key] ||= @resource_name if details[:default_name]
          @attributes[key] ||= details[:default]

          if details[:required] && !@attributes[key]
            raise Resource::AttributeMissingError, "'#{key}' attribute is required but it is not set."
          end

          if @attributes[key] && details[:type] && !@attributes[key].is_a?(details[:type])
            raise Resource::InvalidTypeError, "#{key} attribute should be #{details[:type]}."
          end
        end
      end

      def run_specinfra(type, *args)
        command = Specinfra.command.get(type, *args)
        run_command(command)
      end

      def run_command(command, options = {})
        options = {error: true}.merge(options)

        result = backend.run_command(command)
        exit_status = result.exit_status

        if exit_status == 0 || !options[:error]
          method = :debug
          message = "Command `#{command}` exited with #{exit_status}"
        else
          method = :error
          message = "Command `#{command}` failed. (exit status: #{exit_status})"
        end

        Logger.public_send(method, message)

        if result.stdout && result.stdout != ''
          Logger.public_send(method, "STDOUT> #{result.stdout.chomp}")
        end

        if result.stderr && result.stderr != ''
          Logger.public_send(method, "STDERR> #{result.stderr.chomp}")
        end

        if options[:error] && exit_status != 0
          raise CommandExecutionError
        end

        result
      end

      def copy_file(src, dst)
        Logger.debug "Copying a file from '#{src}' to '#{dst}'..."
        unless ::File.exist?(src)
          raise Error, "The file '#{src}' doesn't exist."
        end
        backend.copy_file(src, dst)
      end

      def only_if(command)
        @only_if_command = command
      end

      def not_if(command)
        @not_if_command = command
      end

      def do_not_run_because_of_only_if?
        @only_if_command &&
          run_command(@only_if_command, error: false).exit_status != 0
      end

      def do_not_run_because_of_not_if?
        @not_if_command &&
          run_command(@not_if_command, error: false).exit_status == 0
      end

      def node
        runner.node
      end

      def backend
        Itamae.backend
      end

      def runner
        @recipe.runner
      end

      def shell_escape(str)
        Shellwords.escape(str)
      end

      def ensure_os
        return unless self.class.supported_oses
        ok = self.class.supported_oses.any? do |supported|
          supported.each_pair.all? do |k, v|
            backend.os[k] == v
          end
        end

        unless ok
          raise NotSupportedOsError, "#{self.class.name} resource doesn't support this OS now."
        end
      end
    end
  end
end

