require 'itamae'
require 'json'
require 'yaml'

module Itamae
  class Runner
    class << self
      def run(recipe_files, backend_type, options)
        Logger.info "Starting Itamae..."

        set_backend_from_options(backend_type, options)

        runner = self.new(node_from_options(options))
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

      private
      def node_from_options(options)
        hash = {}

        if options[:ohai]
          unless Backend.instance.run_command("which ohai", error: false).exit_status == 0
            # install Ohai
            Logger.info "Installing Chef package... (to use Ohai)"
            Backend.instance.run_command("curl -L https://www.opscode.com/chef/install.sh | bash")
          end

          Logger.info "Loading node data via ohai..."
          hash.merge!(JSON.parse(Backend.instance.run_command("ohai").stdout))
        end

        if options[:node_json]
          path = File.expand_path(options[:node_json])
          Logger.info "Loading node data from #{path}..."
          hash.merge!(JSON.load(open(path)))
        end

        if options[:node_yaml]
          path = File.expand_path(options[:node_yaml])
          Logger.info "Loading node data from #{path}..."
          hash.merge!(YAML.load(open(path)))
        end

        Node.new(hash)
      end

      def set_backend_from_options(type, options)
        opts = {}

        case type
        when :local
          # do nothing
        when :ssh
          opts[:host] = options[:host]
          opts[:user] = options[:user] || Etc.getlogin
          opts[:keys] = [options[:key]] if options[:key]
          opts[:port] = options[:port] if options[:port]
          opts[:disable_sudo] = true unless options[:sudo]

          if options[:vagrant]
            config = Tempfile.new('', Dir.tmpdir)
            hostname = opts[:host] || 'default'
            `vagrant ssh-config #{hostname} > #{config.path}`
            opts.merge!(Net::SSH::Config.for(hostname, [config.path]))
            opts[:host] = opts.delete(:host_name)
          end

          if options[:ask_password]
            print "password: "
            password = STDIN.noecho(&:gets).strip
            print "\n"
            opts.merge!(password: password)
          end
        when :dockerfile
          opts[:family] = options[:family]
          opts[:output_dir] = options[:output_dir]
        end

        Backend.instance.set_type(type, opts)
      end
    end

    attr_accessor :node
    attr_accessor :tmpdir
    attr_accessor :children

    def initialize(node)
      @node = node
      @tmpdir = "/tmp/itamae_tmp"
      @children = RecipeChildren.new

      Backend.instance.run_command(["mkdir", "-p", @tmpdir])
      Backend.instance.run_command(["chmod", "777", @tmpdir])
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
    end
  end
end

