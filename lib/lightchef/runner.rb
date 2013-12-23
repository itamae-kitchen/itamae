require 'lightchef'
require 'specinfra'

module Lightchef
  class Runner
    extend SpecInfra::Helper::Backend
    extend SpecInfra::Helper::DetectOS

    def self.run(opts)
      backend = backend_for(:exec)
      opts[:recipe_files].each do |path|
        path = File.expand_path(path)
        recipe = Recipe.new(path, backend)
        recipe.run
      end
    end
  end
end

