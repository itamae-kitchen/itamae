require 'itamae'

module Itamae
  class Recipe
    NotFoundError = Class.new(StandardError)

    attr_reader :path
    attr_reader :runner
    attr_reader :children
    attr_reader :delayed_notifications

    def initialize(runner, path)
      @runner = runner
      @path = path
      @children = RecipeChildren.new
      @delayed_notifications = []

      load_children
    end

    def node
      @runner.node
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

    private

    def load_children
      instance_eval(File.read(@path), @path, 1)
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

      resource = klass.new(self, name, &block)
      @children << resource
    end

    def include_recipe(recipe)
      candidate_paths = [
        ::File.expand_path(recipe, File.dirname(@path)),
        find_recipe_from_load_path(recipe),
      ].compact
      target = candidate_paths.find {|path| File.exist?(path) }

      unless target
        raise NotFoundError, "Recipe not found. (#{recipe})"
      end

      if runner.children.find_recipe_by_path(target)
        Logger.debug "Recipe, #{target}, is skipped because it is already included"
        return
      end

      recipe = Recipe.new(@runner, target)
      @children << recipe
    end

    def find_recipe_from_load_path(recipe)
      target = recipe.gsub('::', '/')
      target += '.rb' if target !~ /\.rb$/
      plugin_name = recipe.split('::')[0]

      spec = Gem.loaded_specs.values.find do |spec|
        spec.name == "itamae-plugin-recipe-#{plugin_name}"
      end

      return nil unless spec

      File.join(spec.lib_dirs_glob, 'itamae', 'plugin', 'recipe', target)
    end

    def define(name, params = {}, &block)
      Resource.const_set(
        Resource.get_resource_class_name(name),
        Definition.create_class(name, params, &block)
      )
    end
  end
end
