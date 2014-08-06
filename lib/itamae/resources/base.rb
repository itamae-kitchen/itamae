require 'itamae'
require 'shellwords'

module Itamae
  module Resources
    class Base
      @defined_options ||= {}
      @supported_oses ||= []

      class << self
        attr_reader :defined_options
        attr_reader :supported_oses

        def inherited(subclass)
          subclass.instance_variable_set(
            :@defined_options,
            self.defined_options.dup
          )
        end

        def define_option(name, options)
          current = @defined_options[name.to_sym] || {}
          @defined_options[name.to_sym] = current.merge(options)
        end

        def support_os(hash)
          @supported_oses << hash
        end
      end

      define_option :action, type: Symbol, required: true

      attr_reader :resource_name
      attr_reader :options

      def initialize(recipe, resource_name, &block)
        @options = {}
        @recipe = recipe
        @resource_name = resource_name

        instance_eval(&block) if block_given?

        process_options
        ensure_os
      end

      def run
        if do_not_run_because_of_only_if?
          Logger.info "Execution skipped because of only_if option"
        elsif do_not_run_because_of_not_if?
          Logger.info "Execution skipped because of not_if option"
        else
          public_send("#{action}_action".to_sym)
        end
      end

      def nothing_action
        # do nothing
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
        command = Specinfra.command.public_send(type, *args)
        run_command(command)
      end

      def run_command(command, options = {})
        options = {raise_error_if_fail: true}.merge(options)

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

        if options[:raise_error_if_fail] && exit_status != 0
          raise CommandExecutionError
        end

        result
      end

      def copy_file(src, dst)
        Logger.debug "Copying a file from '#{src}' to '#{dst}'..."
        unless ::File.exist?(src)
          raise Error, "The file '#{src}' doesn't exist."
        end
        unless backend.copy_file(src, dst)
          raise Error, "Copying a file failed."
        end
      end

      def only_if(command)
        @only_if_command = command
      end

      def not_if(command)
        @not_if_command = command
      end

      def do_not_run_because_of_only_if?
        @only_if_command &&
          run_command(@only_if_command, raise_error_if_fail: false).exit_status != 0
      end

      def do_not_run_because_of_not_if?
        @not_if_command &&
          run_command(@not_if_command, raise_error_if_fail: false).exit_status == 0
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

