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

        temppath = ::File.join(runner.tmpdir, Time.now.to_f.to_s)
        copy_file(src, temppath)

        if mode
          run_specinfra(:change_file_mode, temppath, mode)
        end
        if owner || group
          run_specinfra(:change_file_owner, temppath, owner, group)
        end

        if run_specinfra(:check_file_is_file, path)
          # TODO: specinfra
          run_command(["cp", path, "#{path}.bak"])
        end

        # TODO: specinfra
        run_command(["mv", temppath, path])
      end
    end
  end
end

