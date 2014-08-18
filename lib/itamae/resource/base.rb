require 'itamae'
require 'shellwords'

module Itamae
  module Resource
    class Base
      @defined_attributes ||= {}

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
        @notifies = []
        @subscribes = []
        @updated = false

        instance_eval(&block) if block_given?

        process_attributes
      end

      def run(specific_action = nil, options = {})
        Logger.info "> Executing #{resource_type} (#{attributes})..."

        if do_not_run_because_of_only_if?
          Logger.info "< Execution skipped because of only_if attribute"
          return
        elsif do_not_run_because_of_not_if?
          Logger.info "< Execution skipped because of not_if attribute"
          return
        end

        set_current_attributes
        show_differences

        unless options[:dry_run]
          public_send("#{specific_action || action}_action".to_sym)
        end

        updated! if different?

        notify if updated?

        Logger.info "< Succeeded."
      rescue Resource::CommandExecutionError
        Logger.error "< Failed."
        exit 2
      end

      def nothing_action
        # do nothing
      end

      def resource_type
        humps = []
        self.class.name.split("::").last.each_char do |c|
          if "A" <= c && c <= "Z"
            humps << c.downcase
          else
            humps.last << c
          end
        end
        humps.join('_')
      end

      def notifies_resources
        @notifies.map do |action, resource_desc, timing|
          resource = resources.find_by_description(resource_desc)
          [action, resource, timing]
        end
      end

      def subscribes_resources
        @subscribes.map do |action, resource_desc, timing|
          resource = resources.find_by_description(resource_desc)
          [action, resource, timing]
        end
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
        # do nothing
      end

      def different?
        @current_attributes.each_pair.any? do |key, current_value|
          current_value != @attributes[key]
        end
      end

      def show_differences
        @current_attributes.each_pair do |key, current_value|
          value = @attributes[key]
          if current_value == value
            Logger.info "  #{key} will not change (current value is '#{current_value}')"
          else
            Logger.info "  #{key} will change from '#{current_value}' to '#{value}'"
          end
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

        if type.to_s.start_with?("check_")
          result = run_command(command, error: false)
          result.exit_status == 0
        else
          run_command(command)
        end
      end

      def run_command(command, options = {})
        options = {error: true}.merge(options)

        result = backend.run_command(command)
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

      def copy_file(src, dst)
        Logger.debug "  Copying a file from '#{src}' to '#{dst}'..."
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

      def notifies(action, resource_desc, timing = :delay)
        @notifies << [action, resource_desc, timing]
      end

      def subscribes(action, resource_desc, timing = :delay)
        @subscribes << [action, resource_desc, timing]
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

      def resources
        @recipe.resources
      end

      def shell_escape(str)
        Shellwords.escape(str)
      end

      def updated!
        @updated = true
      end

      def updated?
        @updated
      end

      def notify
        action_resource_timing = notifies_resources + resources.subscribing(self)
        action_resource_timing.uniq.each do |action, resource, timing|
          case timing
          when :immediately
            resource.run(action)
          when :delay
            @recipe.delayed_actions << [action, resource]
          end
        end
      end
    end
  end
end

