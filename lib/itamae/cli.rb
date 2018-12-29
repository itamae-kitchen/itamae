require 'itamae'
require 'thor'

module Itamae
  class CLI < Thor
    GENERATE_TARGETS = %w[cookbook role].freeze

    def initialize(*)
      super

      Itamae.logger.level = ::Logger.const_get(options[:log_level].upcase) if options[:log_level]
      Itamae.logger.formatter.colored = options[:color] if options[:color]
    end

    def self.define_exec_options
      option :recipe_graph, type: :string, desc: "[EXPERIMENTAL] Write recipe dependency graph in DOT", banner: "PATH"
      option :node_json, type: :string, aliases: ['-j']
      option :node_yaml, type: :string, aliases: ['-y']
      option :dry_run, type: :boolean, aliases: ['-n']
      option :shell, type: :string, default: "/bin/sh"
      option :login_shell, type: :boolean, default: false
      option :ohai, type: :boolean, default: false, desc: "This option is DEPRECATED and will be unavailable."
      option :profile, type: :string, desc: "[EXPERIMENTAL] Save profiling data", banner: "PATH"
      option :detailed_exitcode, type: :boolean, default: false, desc: "exit code 0 - The run succeeded with no changes or failures, exit code 1 - The run failed, exit code 2 - The run succeeded, and some resources were changed"
      option :log_level, type: :string, aliases: ['-l'], default: 'info'
      option :color, type: :boolean, default: true
      option :config, type: :string, aliases: ['-c']
    end

    desc "local RECIPE [RECIPE...]", "Run Itamae locally"
    define_exec_options
    def local(*recipe_files)
      if recipe_files.empty?
        raise "Please specify recipe files."
      end

      run(recipe_files, :local, options)
    end

    desc "ssh RECIPE [RECIPE...]", "Run Itamae via ssh"
    define_exec_options
    option :host, type: :string, aliases: ['-h']
    option :user, type: :string, aliases: ['-u']
    option :key, type: :string, aliases: ['-i']
    option :port, type: :numeric, aliases: ['-p']
    option :ssh_config, type: :string
    option :vagrant, type: :boolean, default: false
    option :ask_password, type: :boolean, default: false
    option :sudo, type: :boolean, default: true
    def ssh(*recipe_files)
      if recipe_files.empty?
        raise "Please specify recipe files."
      end

      unless options[:host] || options[:vagrant]
        raise "Please set '-h <hostname>' or '--vagrant'"
      end

      run(recipe_files, :ssh, options)
    end

    desc "docker RECIPE [RECIPE...]", "Create Docker image"
    define_exec_options
    option :image, type: :string, desc: "This option or 'container' option is required."
    option :container, type: :string, desc: "This option or 'image' option is required."
    option :tls_verify_peer, type: :boolean, default: true
    option :tag, type: :string
    def docker(*recipe_files)
      if recipe_files.empty?
        raise "Please specify recipe files."
      end

      run(recipe_files, :docker, options)
    end

    desc "jail RECIPE [RECIPE...]", "Run Itamae in jail"
    define_exec_options
    option :jail_name, type: :string, desc: "Jail Hostname"
    def jail(*recipe_files)
      if recipe_files.empty?
        raise "Please specify recipe files."
      end

      run(recipe_files, :jexec, options)
    end

    desc "version", "Print version"
    def version
      puts "Itamae v#{Itamae::VERSION}"
    end

    desc "init NAME", "Create a new project"
    def init(name)
      generator = Generators::Project.new
      generator.destination_root = name
      generator.invoke_all
    end

    desc 'generate [cookbook|role] [NAME]', 'Initialize role or cookbook (short-cut alias: "g")'
    map 'g' => 'generate'
    def generate(target, name)
      validate_generate_target!('generate', target)

      generator = Generators.find(target).new
      generator.destination_root = File.join("#{target}s", name)
      generator.copy_files
    end

    desc 'destroy [cookbook|role] [NAME]', 'Undo role or cookbook (short-cut alias: "d")'
    map 'd' => 'destroy'
    def destroy(target, name)
      validate_generate_target!('destroy', target)

      generator = Generators.find(target).new
      generator.destination_root = File.join("#{target}s", name)
      generator.remove_files
    end

    private
    def options
      @itamae_options ||= super.dup.tap do |options|
        if config = options[:config]
          options.merge!(YAML.load_file(config))
        end
      end
    end

    def validate_generate_target!(command, target)
      unless GENERATE_TARGETS.include?(target)
        msg = %Q!ERROR: "itamae #{command}" was called with "#{target}" !
        msg << "but expected to be in #{GENERATE_TARGETS.inspect}"
        fail InvocationError, msg
      end
    end

    def run(recipe_files, backend_type, options)
      runner = Runner.run(recipe_files, backend_type, options)
      if options[:detailed_exitcode] && runner.diff?
        exit 2
      end
    end
  end
end
