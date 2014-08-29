require 'itamae'

module Itamae
  module Converger
    class Link < Base

      private

      def pre_action
        case @current_action
        when :create
          resource.attributes[:exist?] = true
        end
      end

      def set_current_attributes
        current_resource.attributes[:exist?] = 
          run_specinfra(:check_file_is_link, resource.link)

        if current_resource.attributes[:exist?]
          current_resource.to run_specinfra(:get_file_link_target, resource.link).stdout.strip
        end
      end

      def action_create(options)
        unless run_specinfra(:check_file_is_linked_to, resource.link, resource.to)
          run_specinfra(:link_file_to, resource.link, resource.to)
        end
      end
    end
  end
end
