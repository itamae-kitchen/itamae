require 'itamae'

module Itamae
  module Resource
    class Directory < Base
      define_attribute :action, default: :create
      define_attribute :path, type: String, default_name: true
      define_attribute :mode, type: String
      define_attribute :owner, type: String
      define_attribute :group, type: String

      def pre_action
        case @current_action
        when :create
          attributes.exist = true
        end
      end

      def show_differences
        current.mode    = current.mode.rjust(4, '0') if current.mode
        attributes.mode = attributes.mode.rjust(4, '0') if attributes.mode

        super
      end

      def set_current_attributes
        exist = run_specinfra(:check_file_is_directory, attributes.path)
        current.exist = exist

        if exist
          current.mode = run_specinfra(:get_file_mode, attributes.path).stdout.chomp
          current.owner = run_specinfra(:get_file_owner_user, attributes.path).stdout.chomp
          current.group = run_specinfra(:get_file_owner_group, attributes.path).stdout.chomp
        else
          current.mode = nil
          current.owner = nil
          current.group = nil
        end
      end

      def action_create(options)
        if !run_specinfra(:check_file_is_directory, attributes.path)
          run_specinfra(:create_file_as_directory, attributes.path)
        end
        if attributes.mode
          run_specinfra(:change_file_mode, attributes.path, attributes.mode)
        end
        if attributes.owner || attributes.group
          run_specinfra(:change_file_owner, attributes.path, attributes.owner, attributes.group)
        end
      end
    end
  end
end

