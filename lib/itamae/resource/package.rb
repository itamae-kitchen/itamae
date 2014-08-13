require 'itamae'

module Itamae
  module Resource
    class Package < Base
      define_attribute :action, default: :install
      define_attribute :name, type: String, default_name: true

      def install_action
        run_specinfra(:install_package, name)
      end
    end
  end
end

