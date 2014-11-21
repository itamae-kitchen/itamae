require 'itamae'
require 'thor'

module Itamae
  class CLI < Thor
    class_option :log_level, type: :string, aliases: ['-l'], default: 'info'
    class_option :color, type: :boolean, default: true

    def initialize(*args)
      super

      Itamae::Logger.level = ::Logger.const_get(options[:log_level].upcase)
      Itamae::Logger.formatter.colored = options[:color]
    end

    desc "local RECIPE [RECIPE...]", "Run Itamae locally"
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
    option :node_json, type: :string, aliases: ['-j']
    option :node_yaml, type: :string, aliases: ['-y']
    option :dry_run, type: :boolean, aliases: ['-n']
    option :host, required: true, type: :string, aliases: ['-h']
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

      Runner.run(recipe_files, :ssh, options)
    end

    desc "dockerfile RECIPE [RECIPE...]", "Create Dockerfile"
    option :node_json, type: :string, aliases: ['-j']
    option :node_yaml, type: :string, aliases: ['-y']
    option :output_dir, type: :string, aliases: ['-o']
    option :family, required: true, type: :string, aliases: ['-f']
    def dockerfile(*recipe_files)
      if recipe_files.empty?
        raise "Please specify recipe files."
      end

      Runner.run(recipe_files, :dockerfile, options)
    end

    desc "version", "Print version"
    def version
      puts "Itamae v#{Itamae::VERSION}"
    end
  end
end

