require 'itamae'

module Itamae
  module Resource
    class Link < Base
      define_attribute :action, default: :create
      define_attribute :link, type: String, default_name: true
      define_attribute :to, type: String, required: true

      def create_action
        if ! run_specinfra(:check_file_is_linked_to, link, to)
          run_specinfra(:link_file_to, link, to)
        end
      end
    end
  end
end
