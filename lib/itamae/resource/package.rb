require 'itamae'

module Itamae
  module Resource
    class Package < Base
      define_attribute :action, default: :install
      define_attribute :name, type: String, default_name: true
      define_attribute :version, type: String
      define_attribute :options, type: String

      def pre_action
        case @current_action
        when :install
          attributes.installed = true
        end
      end

      def set_current_attributes
        current.installed = run_specinfra(:check_package_is_installed, attributes.name)

        if current.installed
          current.version = run_specinfra(:get_package_version, attributes.name).stdout.strip
        end
      end

      def action_install(action_options)
        unless run_specinfra(:check_package_is_installed, attributes.name, attributes.version)
          command = Specinfra.command.get(:install_package, attributes.name, attributes.version, attributes.options)
          run_command(command, {user: attributes.user})
          updated!
        end
      end
    end
  end
end

