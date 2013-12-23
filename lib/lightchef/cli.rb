require 'lightchef'
require 'thor'

module Lightchef
  class CLI < Thor
    desc "execute", "Run Lightchef"
    def execute(*recipe_files)
      Runner.run(recipe_files: recipe_files)
    end
  end
end

