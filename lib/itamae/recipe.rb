require 'itamae'

module Itamae
  class Recipe
    attr_reader :path
    attr_reader :runner
    attr_reader :dependencies
    attr_reader :delayed_actions

    def initialize(runner, path)
      @runner = runner
      @path = path
      @dependencies = RecipeDependencies.new
      @delayed_actions = []

      load_dependencies
    end

    def node
      @runner.node
    end

    def run(options = {})
      Logger.info "Recipe: #{@path}"

      @dependencies.each do |resource|
        case resource
        when Resource::Base
          resource.run(nil, dry_run: options[:dry_run])
        when Recipe
          resource.run(options)
        end
      end

      @delayed_actions.uniq.each do |action, resource|
        resource.run(action, dry_run: options[:dry_run])
      end

      Logger.info "< Finished. (#{@path})"
    end

    private

    def load_dependencies
      instance_eval(File.read(@path), @path, 1)
    end

    def method_missing(method, name, &block)
      klass = Resource.get_resource_class(method)
      resource = klass.new(self, name, &block)
      @dependencies << resource
    rescue NameError
      super
    end

    def include_recipe(target)
      target = ::File.expand_path(target, File.dirname(@path))
      recipe = Recipe.new(@runner, target)
      @dependencies << recipe
    end
  end
end

