require 'itamae'

module Itamae
  module Resource
    class Directory < Base
      define_attribute :action, default: :create
      define_attribute :path, type: String, default_name: true
      define_attribute :mode, type: String
      define_attribute :owner, type: String
      define_attribute :group, type: String

      def set_current_attributes
        if run_specinfra(:check_file_is_directory, path)
          @current_attributes[:mode] = run_specinfra(:get_file_mode, path).stdout.chomp
          @current_attributes[:owner] = run_specinfra(:get_file_owner_user, path).stdout.chomp
          @current_attributes[:group] = run_specinfra(:get_file_owner_group, path).stdout.chomp
        end
      end

      def create_action
        if ! run_specinfra(:check_file_is_directory, path)
          run_specinfra(:create_file_as_directory, path)
        end
        if attributes[:mode]
          run_specinfra(:change_file_mode, path, attributes[:mode])
        end
        if attributes[:owner] || attributes[:group]
          run_specinfra(:change_file_owner, path, attributes[:owner], attributes[:group])
        end
      end
    end
  end
end

