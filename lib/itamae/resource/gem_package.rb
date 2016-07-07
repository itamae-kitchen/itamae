require 'itamae'

module Itamae
  module Resource
    class GemPackage < Base
      define_attribute :action, default: :install
      define_attribute :package_name, type: String, default_name: true
      define_attribute :gem_binary, type: [String, Array], default: 'gem'
      define_attribute :options, type: [String, Array], default: []
      define_attribute :version, type: String
      define_attribute :source, type: String

      def pre_action
        case @current_action
        when :install
          attributes.installed = true
        when :uninstall
          attributes.installed = false
        end
      end

      def set_current_attributes
        installed = installed_gems.find {|g| g[:name] == attributes.package_name }
        current.installed = !!installed

        if current.installed
          versions = installed[:versions]
          if versions.include?(attributes.version)
            current.version = attributes.version
          else
            current.version = versions.first
          end
        end
      end

      def action_install(action_options)
        if current.installed
          if attributes.version && current.version != attributes.version
            install!
            updated!
          end
        else
          install!
          updated!
        end
      end

      def action_uninstall(action_options)
        uninstall! if current.installed
      end

      def action_upgrade(action_options)
        return if current.installed && attributes.version && current.version == attributes.version

        install!
        updated!
      end

      def installed_gems
        gems = []
        run_command([*Array(attributes.gem_binary), 'list', '-l']).stdout.each_line do |line|
          if /\A([^ ]+) \(([^\)]+)\)\z/ =~ line.strip
            name = $1
            versions = $2.split(', ')
            gems << {name: name, versions: versions}
          end
        end
        gems
      rescue Backend::CommandExecutionError
        []
      end

      def install!
        cmd = [*Array(attributes.gem_binary), 'install', *Array(attributes.options)]
        if attributes.version
          cmd << '-v' << attributes.version
        end
        if attributes.source
          cmd << '--source' << attributes.source
        end
        cmd << attributes.package_name

        run_command(cmd)
      end

      def uninstall!
        cmd = [*Array(attributes.gem_binary), 'uninstall', '--ignore-dependencies', '--executables', *Array(attributes.options)]
        if attributes.version
          cmd << '-v' << attributes.version
        else
          cmd << '--all'
        end
        cmd << attributes.package_name

        run_command(cmd)
      end
    end
  end
end
