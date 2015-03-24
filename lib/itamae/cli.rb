require 'itamae'
require 'thor'

module Itamae
  class CLI < Thor
    class_option :log_level, type: :string, aliases: ['-l'], default: 'info'
    class_option :color, type: :boolean, default: true

    def initialize(args, opts, config)
      opts = Config.new(opts).load
      super(args, opts, config)

      Itamae::Logger.level = ::Logger.const_get(options[:log_level].upcase)
      Itamae::Logger.formatter.colored = options[:color]
    end

    desc "local RECIPE [RECIPE...]", "Run Itamae locally"
    option :dot, type: :string, default: nil, desc: "Only write dependency graph in DOT", banner: "PATH"
    option :node_json, type: :string, aliases: ['-j']
    option :node_yaml, type: :string, aliases: ['-y']
    option :dry_run, type: :boolean, aliases: ['-n']
    option :ohai, type: :boolean, default: false
    def local(*recipe_files)
      if recipe_files.empty?
        raise "Please specify recipe files."
      end

      Runner.run(recipe_files, :local, options)
    end

    desc "ssh RECIPE [RECIPE...]", "Run Itamae via ssh"
    option :dot, type: :string, default: nil, desc: "Only write dependency graph in DOT", banner: "PATH"
    option :node_json, type: :string, aliases: ['-j']
    option :node_yaml, type: :string, aliases: ['-y']
    option :dry_run, type: :boolean, aliases: ['-n']
    option :host, type: :string, aliases: ['-h']
    option :user, type: :string, aliases: ['-u']
    option :key, type: :string, aliases: ['-i']
    option :port, type: :numeric, aliases: ['-p']
    option :ohai, type: :boolean, default: false
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
    option :dot, type: :string, default: nil, desc: "Only write dependency graph in DOT", banner: "PATH"
    option :node_json, type: :string, aliases: ['-j']
    option :node_yaml, type: :string, aliases: ['-y']
    option :dry_run, type: :boolean, aliases: ['-n']
    option :ohai, type: :boolean, default: false
    option :image, type: :string, required: true
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
  end
end

