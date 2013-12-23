require 'lightchef'

module Lightchef
  class Recipe
    attr_reader :path
    attr_reader :backend

    def initialize(path, backend)
      @path = path
      @backend = backend
    end

    def run
      instance_eval(File.read(@path), @path, 1)
    end

    def method_missing(method, *args, &block)
      cls = Resources.get_resource_class(method)
      resource = cls.new(self, args, &block)
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

