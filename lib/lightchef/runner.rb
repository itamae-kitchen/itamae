require 'lightchef'
require 'specinfra'

module Lightchef
  class Runner
    extend Specinfra::Helper::Backend

    class << self
      def run(recipe_files, backend, options)
        backend = backend_from_options(backend, options)
        runner = self.new(backend)
        runner.node = node_from_options(options)

        recipe_files.each do |path|
          recipe = Recipe.new(runner, File.expand_path(path))
          recipe.run
        end
      end

      private
      def node_from_options(options)
        if options[:node_json]
          path = File.expand_path(options[:node_json])
          Logger.debug "Loading node data from #{path} ..."
          hash = JSON.load(open(path))
        else
          hash = {}
        end

        Node.new(hash)
      end

      def backend_from_options(type, options)
        case type
        when :local
          Lightchef.create_local_backend
        when :ssh
          ssh_options = {}
          ssh_options[:host] = options[:host]
          ssh_options[:user] = options[:user] || Etc.getlogin
          ssh_options[:keys] = [options[:key]] if options[:key]
          ssh_options[:port] = options[:port] if options[:port]

          Lightchef.create_ssh_backend(ssh_options)
        end
      end
    end

    attr_accessor :backend
    attr_accessor :node

    def initialize(backend)
      @backend = backend
    end
  end
end

