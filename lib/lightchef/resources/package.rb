require 'lightchef'

module Lightchef
  module Resources
    class Package < Base
      define_option :action, default: :install
      define_option :name, type: String, default_name: true

      def install_action
        run_specinfra(:install_package, name)
      end
    end
  end
end

