require 'itamae'
require 'json'
require 'yaml'

module Itamae
  class Runner
    class << self
      def run(recipe_files, backend_type, options)
        Itamae.logger.info "Starting Itamae..."

        backend = Backend.create(backend_type, options)
        runner = self.new(backend, options)
        runner.load_recipes(recipe_files)

        if dot_file = options[:dot]
          runner.save_dependency_graph(dot_file)
          return
        end

        runner.run

        if profile = options[:profile]
          runner.save_profile(profile)
        end
      end
    end

    attr_reader :backend
    attr_reader :options
    attr_reader :node
    attr_reader :tmpdir
    attr_reader :children

    def initialize(backend, options)
      @backend = backend
      @options = options

      prepare_reporters

      @node = create_node
      @tmpdir = "/tmp/itamae_tmp"
      @children = RecipeChildren.new

      @backend.run_command(["mkdir", "-p", @tmpdir])
      @backend.run_command(["chmod", "777", @tmpdir])
    end

    def load_recipes(paths)
      paths.each do |path|
        expanded_path = File.expand_path(path)
        if path.include?('::')
          gem_path = Recipe.find_recipe_in_gem(path)
          expanded_path = gem_path if gem_path
        end

        recipe = Recipe.new(self, expanded_path)
        children << recipe
        recipe.load
      end
    end

    def run
      children.run
      @backend.finalize
    end

    def dry_run?
      @options[:dry_run]
    end

    def save_dependency_graph(path)
      Itamae.logger.info "Writing dependency graph in DOT to #{path}..."
      open(path, 'w') do |f|
        f.write(runner.children.deps_in_dot)
      end
    end

    def save_profile(path)
      open(path, 'w', 0600) do |f|
        f.write(@backend.executed_commands.to_json)
      end
    end

    def report(event_name, *args)
      @reporters.each do |r|
        r.event(event_name, *args)
      end
    end

    def report_with_block(event_name, *args)
      report("#{event_name}_started".to_sym, *args)
      yield
    rescue
      report("#{event_name}_failed".to_sym, *args)
      raise
    else
      report("#{event_name}_completed".to_sym, *args)
    end

    private
    def create_node
      hash = {}

      if @options[:ohai]
        unless @backend.run_command("which ohai", error: false).exit_status == 0
          # install Ohai
          Itamae.logger.info "Installing Chef package... (to use Ohai)"
          @backend.run_command("curl -L https://www.opscode.com/chef/install.sh | bash")
        end

        Itamae.logger.info "Loading node data via ohai..."
        hash.merge!(JSON.parse(@backend.run_command("ohai").stdout))
      end

      if @options[:node_json]
        path = File.expand_path(@options[:node_json])
        Itamae.logger.info "Loading node data from #{path}..."
        hash.merge!(JSON.load(open(path)))
      end

      if @options[:node_yaml]
        path = File.expand_path(@options[:node_yaml])
        Itamae.logger.info "Loading node data from #{path}..."
        hash.merge!(YAML.load(open(path)) || {})
      end

      Node.new(hash, @backend)
    end

    def prepare_reporters
      @reporters = (@options[:reporters] || []).map do |reporter|
        type = reporter.delete('type')
        unless type
          raise "#{type} field is not set"
        end
        Reporter.from_type(type).new(reporter)
      end
    end
  end
end
