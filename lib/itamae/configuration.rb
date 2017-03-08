module Itamae
  class Configuration
    def initialize
      @logger = ::Logger.new($stdout).tap do |l|
        l.formatter = Itamae::Logger::Formatter.new
      end.extend(Itamae::Logger::Helper)
    end

    def logger
      @logger
    end

    def logger=(l)
      @logger = l.extend(Itamae::Logger::Helper)
    end

    def default_recipes
      @default_recipes ||= []
    end

    def add_recipe(path)
      default_recipes << path
    end

    def prepend_recipe(path)
      default_recipes.unshift path
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configuration=(value)
      @configuration = value
    end

    def configure(&blokc)
      configuration.instance_eval &block
    end

    def logger
      configuration.logger
    end

    def logger=(l)
      configuration.logger = l
    end
  end
end
