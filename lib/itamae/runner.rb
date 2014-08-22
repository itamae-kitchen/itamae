require 'itamae'
require 'json'

module Itamae
  class Runner
    class << self
      def run(recipe_files, backend_type, options)
        Logger.info "Starting Itamae..."

        set_backend_from_options(backend_type, options)

        runner = self.new(node_from_options(options))

        recipe_files.each do |path|
          recipe = Recipe.new(runner, File.expand_path(path))
          recipe.run(dry_run: options[:dry_run])
        end
      end

      private
      def node_from_options(options)
        hash = {}

        if options[:ohai]
          unless Backend.instance.run_command("which ohai", error: false).exit_status == 0
            # install Chef (I'd like to replace Ohai with single binary...)
            Logger.info "Installing Chef to use Ohai..."
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
        end

        Backend.instance.set_type(type, opts)
      end
    end

    attr_accessor :node
    attr_accessor :tmpdir

    def initialize(node)
      @node = node
      @tmpdir = "/tmp/itamae_tmp"

      Backend.instance.run_command(["mkdir", "-p", @tmpdir])
      Backend.instance.run_command(["chmod", "777", @tmpdir])
    end
  end
end

