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
        escaped_path = shell_escape(path)
        if run_command("test -d #{escaped_path}", error: false).exit_status == 0
          @current_attributes[:mode] = run_command("stat --format '%a' #{escaped_path}").stdout.chomp
          @current_attributes[:owner] = run_command("stat --format '%U' #{escaped_path}").stdout.chomp
          @current_attributes[:group] = run_command("stat --format '%G' #{escaped_path}").stdout.chomp
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

