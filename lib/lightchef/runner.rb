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
          recipe = Recipe.new(File.expand_path(path))
          recipe.run(runner)
        end
      end

      private
      def node_from_options(options)
        if options[:node_json]
          node_json_path = File.expand_path(options[:node_json])
          Logger.debug "Loading node data from #{node_json_path} ..."
          Node.new_from_file(node_json_path)
        else
          Node.new
        end
      end

      def backend_from_options(type, options)
        case type
        when :exec
          Lightchef.create_backend(:exec)
        when :ssh
          ssh_options = {}
          ssh_options[:user] = options[:user] || Etc.getlogin
          ssh_options[:keys] = [options[:key]] if options[:key]
          ssh_options[:port] = options[:port] if options[:port]

          Specinfra.configuration.host = options[:host]
          Specinfra.configuration.ssh_options = ssh_options

          Lightchef.create_backend(:ssh)
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

