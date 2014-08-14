require 'itamae'

module Itamae
  class Recipe
    attr_reader :path
    attr_reader :runner

    def initialize(runner, path)
      @runner = runner
      @path = path
      @resources = ResourceCollection.new
      load_resources
    end

    def node
      @runner.node
    end

    def run
      @resources.each do |resource|
        Logger.info ">>> Executing #{resource.class.name} (#{resource.attributes})..."
        begin
          resource.run
        rescue Resource::CommandExecutionError
          Logger.error "<<< Failed."
          exit 2
        else
          Logger.info "<<< Succeeded."
        end
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

