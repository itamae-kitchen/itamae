require 'json'
require 'yaml'

module Itamae
  class Runner
    class << self
      def run(recipe_files, backend_type, options)
        unless recipe_files.is_a? Array
          raise ArgumentError, 'recipe_files must be an Array'
        end

        Itamae.logger.info "Starting Itamae... #{options[:dry_run] ? '(dry-run)' : ''}"

        backend = Backend.create(backend_type, options)
        runner = self.new(backend, options)
        runner.load_recipes(recipe_files)
        runner.run

        runner
      end
    end

    attr_reader :backend
    attr_reader :options
    attr_reader :node
    attr_reader :tmpdir
    attr_reader :children
    attr_reader :handler

    def initialize(backend, options)
      @backend = backend
      @options = options

      prepare_handler

      @node = create_node
      @tmpdir = options[:tmp_dir] || '/tmp/itamae_tmp'
      @children = RecipeChildren.new
      @diff = false

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
      if recipe_graph_file = options[:recipe_graph]
        save_dependency_graph(recipe_graph_file)
      end

      children.run
      @backend.finalize

      if profile = options[:profile]
        save_profile(profile)
      end
    end

    def dry_run?
      @options[:dry_run]
    end

    def save_dependency_graph(path)
      Itamae.logger.info "Writing recipe dependency graph to #{path}..."
      open(path, 'w') do |f|
        f.write(children.dependency_in_dot)
      end
    end

    def save_profile(path)
      open(path, 'w', 0600) do |f|
        f.write(@backend.executed_commands.to_json)
      end
    end

    def diff?
      @diff
    end

    def diff_found!
      @diff = true
    end

    private

    def create_node
      hash = {}
      hash.extend(Hashie::Extensions::DeepMerge)

      if @options[:ohai]
        unless @backend.run_command("which ohai", error: false).exit_status == 0
          # install Ohai
          Itamae.logger.info "Installing Chef package... (to use Ohai)"
          @backend.run_command("curl -L https://omnitruck.chef.io/install.sh | bash")
        end

        Itamae.logger.info "Loading node data via ohai..."
        hash.merge!(JSON.parse(@backend.run_command("ohai 2>/dev/null").stdout))
      end

      @options.fetch(:node_json, []).each do |name|
        path = File.expand_path(name)
        Itamae.logger.info "Loading node data from #{path}..."

        hash.deep_merge!(JSON.parse(File.read(path)))
      end

      @options.fetch(:node_yaml, []).each do |name|
        path = File.expand_path(name)
        Itamae.logger.info "Loading node data from #{path}..."

        yaml = YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(File.read(path)) : YAML.load(File.read(path))
        hash.deep_merge!(yaml || {})
      end

      # 'hash.dup' ensures that we pass a pristine Hash object without Hashie extensions
      Node.new(hash.dup, @backend)
    end

    def prepare_handler
      @handler = HandlerProxy.new
      (@options[:handlers] || []).each do |handler|
        type = handler.delete('type')
        unless type
          raise "#{type} field is not set"
        end
        @handler.register_instance(Handler.from_type(type).new(handler))
      end
    end
  end
end
