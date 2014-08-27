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
          @attributes[:installed?] = true
        end
      end

      def set_current_attributes
        installed = run_specinfra(:check_package_is_installed, name)
        @current_attributes[:installed?] = installed

        if installed
          @current_attributes[:version] = run_specinfra(:get_package_version, name).stdout.strip
        end
      end

      def install_action(action_options)
        unless run_specinfra(:check_package_is_installed, name, version)
          run_specinfra(:install_package, name, version, options)
          updated!
        end
      end
    end
  end
end

