require 'itamae'

module Itamae
  class Recipe
    attr_reader :path
    attr_reader :runner
    attr_reader :resources
    attr_reader :delayed_actions

    def initialize(runner, path)
      @runner = runner
      @path = path
      @resources = ResourceCollection.new
      @delayed_actions = []

      load_resources
    end

    def node
      @runner.node
    end

    def run(options = {})
      @resources.each do |resource|
        # do action specified in the recipe
        resource.run(nil, dry_run: options[:dry_run])
      end

      @delayed_actions.uniq.each do |action, resource|
        resource.run(action, dry_run: options[:dry_run])
      end
    end

    private

    def load_resources
      instance_eval(File.read(@path), @path, 1)
    end

    def method_missing(method, name, &block)
      klass = Resource.get_resource_class(method)
      resource = klass.new(self, name, &block)
      @resources << resource
    end
  end
end

