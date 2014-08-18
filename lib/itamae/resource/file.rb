require 'itamae'

module Itamae
  module Resource
    class File < Base
      define_attribute :action, default: :create
      define_attribute :path, type: String, default_name: true
      define_attribute :content, type: String, default: ''
      define_attribute :content_file, type: String
      define_attribute :mode, type: String
      define_attribute :owner, type: String
      define_attribute :group, type: String

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
          run_specinfra(:change_file_mode, path, mode)
        end
        if owner || group
          run_specinfra(:change_file_owner, path, owner, group)
        end
      end
    end
  end
end

