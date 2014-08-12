require 'itamae'

module Itamae
  module Resource
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
                Tempfile.open('itamae') do |f|
                  f.write(content)
                  f.path
                end
              end

        copy_file(src, path)

        if mode
          backend.change_file_mode(path, mode)
        end
        if owner || group
          backend.change_file_owner(path, owner, group)
        end
      end
    end
  end
end

