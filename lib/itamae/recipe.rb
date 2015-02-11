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

      context = EvalContext.new(self)
      @children = context.children
    end

    def run(options = {})
      Logger.info "Recipe: #{@path}"

      Logger.formatter.indent do
        @children.run(options)

        @delayed_notifications.uniq do |notification|
          [notification.action, notification.action_resource]
        end.each do |notification|
          notification.run(options)
        end
      end
    end

    class EvalContext
      attr_reader :children

      def initialize(recipe)
        @recipe = recipe
        @children = RecipeChildren.new

        instance_eval(File.read(@recipe.path), @recipe.path, 1)
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
        @children << resource
      end

      def define(name, params = {}, &block)
        class_name = "Itamae::Resource::#{Resource.get_resource_class_name(name)}"
        if Module.const_defined?(class_name) && Module.const_get(class_name).is_a?(Class)
          Logger.warn "Redefine class. (#{class_name})"
          return
        end

        Resource.const_set(
          Resource.get_resource_class_name(name),
          Definition.create_class(name, params, &block)
        )
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
          Logger.debug "Recipe, #{target}, is skipped because it is already included"
          return
        end

        recipe = Recipe.new(runner, path)
        @children << recipe
      end

      def node
        runner.node
      end

      def runner
        @recipe.runner
      end
    end
  end
end
