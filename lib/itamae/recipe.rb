require 'itamae'

module Itamae
  class Recipe
    NotFoundError = Class.new(StandardError)

    attr_reader :path
    attr_reader :runner
    attr_reader :children
    attr_reader :delayed_notifications

    class << self
      def find_recipe_in_gem(recipe)
        plugin_name, recipe_file = recipe.split('::', 2)
        recipe_file = recipe_file.gsub("::", "/") if recipe_file

        gem_name = "itamae-plugin-recipe-#{plugin_name}"
        begin
          gem gem_name
        rescue LoadError
        end
        spec = Gem.loaded_specs.values.find do |spec|
          spec.name == gem_name
        end

        return nil unless spec

        candidate_files = []
        if recipe_file
          recipe_file += '.rb' unless recipe_file.end_with?('.rb')
          candidate_files << "#{plugin_name}/#{recipe_file}"
        else
          candidate_files << "#{plugin_name}/default.rb"
          candidate_files << "#{plugin_name}.rb"
        end

        candidate_files.map do |file|
          File.join(spec.lib_dirs_glob, 'itamae', 'plugin', 'recipe', file)
        end.find do |path|
          File.exist?(path)
        end
      end
    end

    def initialize(runner, path)
      @runner = runner
      @path = path
      @delayed_notifications = []
      @children = RecipeChildren.new
    end

    def dir
      ::File.dirname(@path)
    end

    def load(vars = {})
      context = EvalContext.new(self, vars)
      context.instance_eval(File.read(path), path, 1)
    end

    def run
      show_banner

      @runner.handler.event(:recipe, path: @path) do
        Itamae.logger.with_indent do
          @children.run
          run_delayed_notifications
        end
      end
    end

    private

    def run_delayed_notifications
      @delayed_notifications.uniq! do |notification|
        [notification.action, notification.action_resource]
      end

      while notification = @delayed_notifications.shift
        notification.run
      end
    end

    def show_banner
      Itamae.logger.info "Recipe: #{@path}"
    end

    class EvalContext
      def initialize(recipe, vars)
        @recipe = recipe

        vars.each do |k, v|
          define_singleton_method(k) { v }
        end
      end

      def respond_to_missing?(method, include_private = false)
        Resource.get_resource_class(method)
        true
      rescue NameError
        false
      end

      def method_missing(*args, &block)
        super unless args.size == 2

        method, name = args
        begin
          klass = Resource.get_resource_class(method)
        rescue NameError
          super
        end

        resource = klass.new(@recipe, name, &block)
        @recipe.children << resource
      end

      def define(name, params = {}, &block)
        Resource.define_resource(name, Definition.create_class(name, params, @recipe, &block))
      end

      def include_recipe(target)
        expanded_path = ::File.expand_path(target, File.dirname(@recipe.path))
        expanded_path = ::File.join(expanded_path, 'default.rb') if ::Dir.exist?(expanded_path)
        expanded_path.concat('.rb') unless expanded_path.end_with?('.rb')
        candidate_paths = [expanded_path, Recipe.find_recipe_in_gem(target)].compact
        path = candidate_paths.find {|path| File.exist?(path) }

        unless path
          raise NotFoundError, "Recipe not found. (#{target})"
        end

        if runner.children.find_recipe_by_path(path)
          Itamae.logger.debug "Recipe, #{path}, is skipped because it is already included"
          return
        end

        recipe = Recipe.new(runner, path)
        @recipe.children << recipe
        recipe.load
      end

      def node
        runner.node
      end

      def runner
        @recipe.runner
      end

      def run_command(*args)
        runner.backend.run_command(*args)
      end
    end

    class RecipeFromDefinition < Recipe
      attr_accessor :definition

      def load(vars = {})
        context = EvalContext.new(self, vars)
        context.instance_eval(&@definition.class.definition_block)
      end

      def run
        if @definition.do_not_run_because_of_only_if?
          Itamae.logger.debug "#{@definition.resource_type}[#{@definition.resource_name}] Execution skipped because of only_if attribute"
          return
        elsif @definition.do_not_run_because_of_not_if?
          Itamae.logger.debug "#{@definition.resource_type}[#{@definition.resource_name}] Execution skipped because of not_if attribute"
          return
        end

        super
      end

      private

      def show_banner
        Itamae.logger.debug "#{@definition.resource_type}[#{@definition.resource_name}]"
      end
    end
  end
end
