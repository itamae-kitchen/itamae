require 'lightchef'
require 'specinfra'

module Lightchef
  class Runner
    extend SpecInfra::Helper::Backend
    extend SpecInfra::Helper::DetectOS

    def self.new_from_options(options)
      self.new(backend_for(:exec)).tap do |runner|
        node = if options[:node_json]
                 node_json_path = File.expand_path(options[:node_json])
                 Logger.debug "Loading node data from #{node_json_path} ..."
                 Node.new_from_file(node_json_path)
               else
                 Node.new
               end
        runner.node = node
      end
    end

    def self.run(recipe_files, options={})
      runner = new_from_options(options)

      recipe_files.each do |path|
        recipe = Recipe.new(File.expand_path(path))
        recipe.run(runner)
      end
    end

    attr_accessor :backend
    attr_accessor :node

    def initialize(backend)
      @backend = backend
    end
  end
end

