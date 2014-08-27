require 'itamae'

module Itamae
  module Resource
    class Link < Base
      define_attribute :action, default: :create
      define_attribute :link, type: String, default_name: true
      define_attribute :to, type: String, required: true

      def pre_action
        case @current_action
        when :create
          @attributes[:exist?] = true
        end
      end

      def set_current_attributes
        @current_attributes[:exist?] = run_specinfra(:check_file_is_link, link)

        if @current_attributes[:exist?]
          @current_attributes[:to] = run_specinfra(:get_file_link_target, link).stdout.strip
        end
      end

      def create_action(options)
        unless run_specinfra(:check_file_is_linked_to, link, to)
          run_specinfra(:link_file_to, link, to)
        end
      end
    end
  end
end
