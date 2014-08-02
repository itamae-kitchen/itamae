require 'lightchef'

module Lightchef
  class Recipe
    attr_reader :path
    attr_reader :runner

    def initialize(runner, path)
      @runner = runner
      @path = path
    end

    def run
      instance_eval(File.read(@path), @path, 1)
    end

    def node
      @runner.node
    end

    def method_missing(method, name = nil, &block)
      klass = Resources.get_resource_class(method)
      resource = klass.new(self, name, &block)
      Logger.info ">>> Executing #{resource.class.name} (#{resource.options})..."
      begin
        resource.run
      rescue Resources::CommandExecutionError
        Logger.error "<<< Failed."
        exit 2
      else
        Logger.info "<<< Succeeded."
      end
    end
  end
end

