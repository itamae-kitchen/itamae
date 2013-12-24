require 'lightchef'
require 'thor'

module Lightchef
  class CLI < Thor
    desc "execute", "Run Lightchef"
    option :node_json, type: :string, aliases: ['-j']
    def execute(*recipe_files)
      Runner.run(recipe_files, options)
    end
  end
end

