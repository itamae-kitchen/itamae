require 'lightchef'

module Lightchef
  module Resources
    class File < Base
      define_option :action, default: :create
      define_option :path, type: String, default_name: true
      define_option :content, type: String, default: ''
      define_option :content_file, type: String
      define_option :mode, type: String
      define_option :owner, type: String
      define_option :group, type: String

      def create_action
        src = if content_file
                content_file
              else
                Tempfile.open('lightchef') do |f|
                  f.write(content)
                  f.path
                end
              end

        copy_file(src, path)

        escaped_path = shell_escape(path)
        if mode
          run_command("chmod #{mode} #{escaped_path}")
        end
        if owner || group
          run_command("chown #{owner}:#{group} #{escaped_path}")
        end
      end
    end
  end
end

