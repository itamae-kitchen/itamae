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

      def pre_action
        src = if content_file
                content_file
              else
                Tempfile.open('itamae') do |f|
                  f.write(content)
                  f.path
                end
              end

        @temppath = ::File.join(runner.tmpdir, Time.now.to_f.to_s)
        send_file(src, @temppath)
      end

      def set_current_attributes
        exist = run_specinfra(:check_file_is_file, path)
        @current_attributes[:exist?] = exist

        if exist
          @current_attributes[:mode] = run_specinfra(:get_file_mode, path).stdout.chomp
          @current_attributes[:owner] = run_specinfra(:get_file_owner_user, path).stdout.chomp
          @current_attributes[:group] = run_specinfra(:get_file_owner_group, path).stdout.chomp
        else
          @current_attributes[:mode] = nil
          @current_attributes[:owner] = nil
          @current_attributes[:group] = nil
        end

        if action == :create
          @attributes[:exist?] = true
        end
      end

      def show_differences
        super

        if @current_attributes[:exist?]
          diff = run_command(["diff", "-u", path, @temppath], error: false)
          if diff.exit_status == 0
            # no change
            Logger.info "  file content will not change"
          else
            Logger.info "  diff:"
            diff.stdout.each_line do |line|
              Logger.info "    #{line.strip}"
            end
          end
        end
      end

      def create_action
        if mode
          run_specinfra(:change_file_mode, @temppath, mode)
        end
        if owner || group
          run_specinfra(:change_file_owner, @temppath, owner, group)
        end

        if run_specinfra(:check_file_is_file, path)
          run_specinfra(:copy_file, path, "#{path}.bak")
        end

        run_specinfra(:move_file, @temppath, path)
      end

      def delete_action
        if run_specinfra(:check_file_is_file, path)
          # TODO: delegate to Specinfra
          run_command(["rm", path])
        end
      end
    end
  end
end

