require 'itamae'

module Itamae
  class Recipe
    NotFoundError = Class.new(StandardError)

    attr_reader :path
    attr_reader :runner
    attr_reader :children
    attr_reader :delayed_actions

    def initialize(runner, path)
      @runner = runner
      @path = path
      @children = RecipeChildren.new
      @delayed_actions = []

      load_children
    end

    def node
      @runner.node
    end

    def run(options = {})
      Logger.info "Recipe: #{@path}"

      @children.run(options)

      @delayed_actions.uniq.each do |action, resource|
        resource.run(action, dry_run: options[:dry_run])
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

    def include_recipe(target)
      target = ::File.expand_path(target, File.dirname(@path))

      unless File.exist?(target)
        raise NotFoundError, "File not found. (#{target})"
      end

      if runner.children.find_recipe_by_path(target)
        Logger.debug "Recipe, #{target}, is skipped because it is already included"
        return
      end

      recipe = Recipe.new(@runner, target)
      @children << recipe
    end
  end
end

