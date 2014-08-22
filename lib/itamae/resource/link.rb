require 'itamae'

module Itamae
  module Resource
    class Link < Base
      define_attribute :action, default: :create
      define_attribute :link, type: String, default_name: true
      define_attribute :to, type: String, required: true

      def pre_action
        case action
        when :create
          @attributes[:exist?] = true
        end
      end

      def set_current_attributes
        @current_attributes[:exist?] = (run_command(["test", "-L", link], error: false).exit_status == 0)

        if @current_attributes[:exist?]
          @current_attributes[:to] = run_command(["readlink", "-f", link]).stdout.strip
        end
      end

      def create_action
        unless run_specinfra(:check_file_is_linked_to, link, to)
          run_specinfra(:link_file_to, link, to)
        end
      end
    end
  end
end
