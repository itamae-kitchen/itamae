require 'itamae'

module Itamae
  class Definition
    def self.create_class(name, params, block)
      Class.new(self)
    end

    def initialize(recipe, name, &block)
    end
  end
end

