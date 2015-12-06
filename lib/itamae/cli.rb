require 'itamae'
require 'thor'

module Itamae
  class CLI < Thor
    GENERATE_TARGETS = %w[cookbook role].freeze

    class_option :log_level, type: :string, aliases: ['-l'], default: 'info'
    class_option :color, type: :boolean, default: true
    class_option :config, type: :string, aliases: ['-c']

    def initialize(*)
      super

      Itamae.logger.level = ::Logger.const_get(options[:log_level].upcase)
      Itamae.logger.formatter.colored = options[:color]
    end

    def self.define_exec_options
      option :dot, type: :string, default: nil, desc: "[EXPERIMENTAL] Only write dependency graph in DOT", banner: "PATH"
      option :node_json, type: :string, aliases: ['-j']
      option :node_yaml, type: :string, aliases: ['-y']
      option :dry_run, type: :boolean, aliases: ['-n']
      option :shell, type: :string, default: "/bin/sh"
      option :ohai, type: :boolean, default: false, desc: "This option is DEPRECATED and will be unavailable."
      option :profile, type: :string, desc: "[EXPERIMENTAL] Save profiling data", banner: "PATH"
    end

    desc "local RECIPE [RECIPE...]", "Run Itamae locally"
    define_exec_options
    def local(*recipe_files)
      if recipe_files.empty?
        raise "Please specify recipe files."
      end

      Runner.run(recipe_files, :local, options)
    end

    desc "ssh RECIPE [RECIPE...]", "Run Itamae via ssh"
    define_exec_options
    option :host, type: :string, aliases: ['-h']
    option :user, type: :string, aliases: ['-u']
    option :key, type: :string, aliases: ['-i']
    option :port, type: :numeric, aliases: ['-p']
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

      Runner.run(recipe_files, :ssh, options)
    end

    desc "docker RECIPE [RECIPE...]", "Create Docker image"
    define_exec_options
    option :image, type: :string, desc: "This option or 'container' option is required."
    option :container, type: :string, desc: "This option or 'image' option is required."
    option :tls_verify_peer, type: :boolean, default: true
    def docker(*recipe_files)
      if recipe_files.empty?
        raise "Please specify recipe files."
      end

      Runner.run(recipe_files, :docker, options)
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
  end
end
