require 'lightchef'

module Lightchef
  class Recipe
    attr_reader :path
    attr_reader :backend
    attr_reader :current_runner

    def initialize(path)
      @path = path
    end

    def run(runner)
      @current_runner = runner
      instance_eval(File.read(@path), @path, 1)
      @current_runner = nil
    end

    def node
      @current_runner.node
    end

    def method_missing(method, name = nil, &block)
      cls = Resources.get_resource_class(method)
      resource = cls.new(self, name, &block)
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

