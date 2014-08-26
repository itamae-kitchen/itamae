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

      @children.run(options)

      @delayed_notifications.uniq do |notification|
        [notification.action, notification.action_resource]
      end.each do |notification|
        notification.run(options)
      end

      Logger.info "< Finished. (#{@path})"
    end

    private

    def load_children
      instance_eval(File.read(@path), @path, 1)
    end

    def method_missing(method, name, &block)
      klass = Resource.get_resource_class(method)
      resource = klass.new(self, name, &block)
      @children << resource
    rescue NameError
      super
    end

    def include_recipe(recipe)
      candidate_paths = [
        ::File.expand_path(recipe, File.dirname(@path)),
        find_recipe_from_load_path(recipe),
      ].compact
      target = candidate_paths.find {|path| File.exist?(path) }

      unless target
        raise NotFoundError, "File not found. (#{target})"
      end

      if runner.children.find_recipe_by_path(target)
        Logger.debug "Recipe, #{target}, is skipped because it is already included"
        return
      end

      recipe = Recipe.new(@runner, target)
      @children << recipe
    end

    def find_recipe_from_load_path(recipe)
      target = recipe.gsub(/::/, '/')
      target += '.rb' if target !~ /\.rb$/
      plugin_name = recipe.split('::')[0]

      $LOAD_PATH.find do |path|
        if path =~ %r{/itamae-plugin-recipe-#{plugin_name}/}
          File.join(path, 'itamae', 'plugin', 'recipe', target)
        end
      end
    end
  end
end
