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
        when :remove
          attributes.installed = false
        end
      end

      def set_current_attributes
        current.installed = run_specinfra(:check_package_is_installed, attributes.name)

        if current.installed
          current.version = run_specinfra(:get_package_version, attributes.name).stdout.strip
        end
      end

      def action_install(action_options)
        return if !attributes.version && current.installed

        unless run_specinfra(:check_package_is_installed, attributes.name, attributes.version)
          run_specinfra(:install_package, attributes.name, attributes.version, attributes.options)
          updated!
        end
      end

      def action_upgrade(action_options)
        run_specinfra(:install_package, attributes.name, attributes.version, attributes.options)
        attributes.version = run_specinfra(:get_package_version, attributes.name).stdout.strip
        attributes.installed = run_specinfra(:check_package_is_installed, attributes.name)
        if !current.installed || attributes.version != current.version
          show_differences
          updated!
        end
      end

      def action_remove(action_options)
        if current.installed
          run_specinfra(:remove_package, attributes.name, attributes.options)
          updated!
        end
      end
    end
  end
end

