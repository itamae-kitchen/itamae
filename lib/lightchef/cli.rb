require 'lightchef'
require 'thor'

module Lightchef
  class CLI < Thor
    desc "local RECIPE [RECIPE...]", "Run Lightchef locally"
    option :node_json, type: :string, aliases: ['-j']
    def local(*recipe_files)
      Runner.run(recipe_files, :local, options)
    end

    desc "ssh RECIPE [RECIPE...]", "Run Lightchef via ssh"
    option :node_json, type: :string, aliases: ['-j']
    option :host, required: true, type: :string, aliases: ['-h']
    option :user, type: :string, aliases: ['-u']
    option :key, type: :string, aliases: ['-i']
    option :port, type: :numeric, aliases: ['-p']
    def ssh(*recipe_files)
      Runner.run(recipe_files, :ssh, options)
    end
  end
end

