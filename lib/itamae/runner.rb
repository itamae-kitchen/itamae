require 'itamae'
require 'json'
require 'yaml'

module Itamae
  class Runner
    class << self
      def run(recipe_files, backend_type, options)
        Logger.info "Starting Itamae..."

        backend = Backend.create(backend_type, options)
        runner = self.new(backend, options)
        runner.load_recipes(recipe_files)

        if dot_file = options[:dot]
          Logger.info "Writing dependency graph in DOT to #{dot_file}..."
          open(dot_file, 'w') do |f|
            f.write(runner.children.deps_in_dot)
          end
          return
        end

        runner.run(dry_run: options[:dry_run])
      end
    end

    attr_reader :backend
    attr_reader :node
    attr_reader :tmpdir
    attr_reader :children

    def initialize(backend, options)
      @backend = backend
      @options = options

      @node = create_node
      @tmpdir = "/tmp/itamae_tmp"
      @children = RecipeChildren.new

      @backend.run_command(["mkdir", "-p", @tmpdir])
      @backend.run_command(["chmod", "777", @tmpdir])
    end

    def load_recipes(paths)
      paths.each do |path|
        recipe = Recipe.new(self, File.expand_path(path))
        children << recipe
        recipe.load
      end
    end

    def run(options)
      children.run(options)
      @backend.finalize
    end

    private
    def create_node
      hash = {}

      if @options[:ohai]
        unless @backend.run_command("which ohai", error: false).exit_status == 0
          # install Ohai
          Logger.info "Installing Chef package... (to use Ohai)"
          @backend.run_command("curl -L https://www.opscode.com/chef/install.sh | bash")
        end

        Logger.info "Loading node data via ohai..."
        hash.merge!(JSON.parse(@backend.run_command("ohai").stdout))
      end

      if @options[:node_json]
        path = File.expand_path(@options[:node_json])
        Logger.info "Loading node data from #{path}..."
        hash.merge!(JSON.load(open(path)))
      end

      if @options[:node_yaml]
        path = File.expand_path(@options[:node_yaml])
        Logger.info "Loading node data from #{path}..."
        hash.merge!(YAML.load(open(path)))
      end

      Node.new(hash, @backend)
    end
  end
end

