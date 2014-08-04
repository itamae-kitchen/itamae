require 'lightchef'

module Lightchef
  module Resources
    class Directory < Base
      define_option :action, default: :create
      define_option :path, type: String, default_name: true
      define_option :mode, type: String
      define_option :owner, type: String
      define_option :group, type: String

      def create_action
        escaped_path = shell_escape(path)
        run_command("test -d #{escaped_path} || mkdir #{escaped_path}")
        if options[:mode]
          backend.change_file_mode(path, options[:mode])
        end
        if options[:owner] || options[:group]
          backend.change_file_owner(path, options[:owner], options[:group])
        end
      end
    end
  end
end

