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
        target = recipe.gsub('::', '/')
        target += '.rb' if target !~ /\.rb$/
        plugin_name = recipe.split('::')[0]

        spec = Gem.loaded_specs.values.find do |spec|
          spec.name == "itamae-plugin-recipe-#{plugin_name}"
        end

        return nil unless spec

        File.join(spec.lib_dirs_glob, 'itamae', 'plugin', 'recipe', target)
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

    def run(options = {})
      show_banner

      Logger.formatter.with_indent do
        @children.run(options)

        @delayed_notifications.uniq do |notification|
          [notification.action, notification.action_resource]
        end.each do |notification|
          notification.run(options)
        end
      end
    end

    private

    def show_banner
      Logger.info "Recipe: #{@path}"
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
        candidate_paths = [
          ::File.expand_path(target, File.dirname(@recipe.path)),
          Recipe.find_recipe_in_gem(target),
        ].compact
        path = candidate_paths.find {|path| File.exist?(path) }

        unless path
          raise NotFoundError, "Recipe not found. (#{target})"
        end

        if runner.children.find_recipe_by_path(path)
          Logger.debug "Recipe, #{path}, is skipped because it is already included"
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
    end

    class RecipeFromDefinition < Recipe
      attr_accessor :definition

      def load(vars = {})
        context = EvalContext.new(self, vars)
        context.instance_eval(&@definition.class.definition_block)
      end

      private

      def show_banner
        Logger.debug "#{@definition.resource_type}[#{@definition.resource_name}]"
      end
    end
  end
end
