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
        begin
          src = if content_file
                  ::File.expand_path(content_file, ::File.dirname(@recipe.path))
                else
                  f = Tempfile.open('itamae')
                  f.write(content)
                  f.close
                  f.path
                end

          @temppath = ::File.join(runner.tmpdir, Time.now.to_f.to_s)
          send_file(src, @temppath)
        ensure
          f.unlink if f
        end

        case @current_action
        when :create
          @attributes[:exist?] = true
        end
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
      end

      def show_differences
        super

        if @current_attributes[:exist?]
          diff = run_command(["diff", "-u", path, @temppath], error: false)
          if diff.exit_status == 0
            # no change
            Logger.debug "file content will not change"
          else
            Logger.info "diff:"
            diff.stdout.each_line do |line|
              Logger.info "#{line.strip}"
            end
          end
        end
      end

      def action_create(options)
        if mode
          run_specinfra(:change_file_mode, @temppath, mode)
        end
        if owner || group
          run_specinfra(:change_file_owner, @temppath, owner, group)
        end

        if run_specinfra(:check_file_is_file, path)
          run_specinfra(:copy_file, path, "#{path}.bak")

          unless check_command(["diff", "-q", @temppath, path])
            # the file is modified
            updated!
          end
        else
          # new file
          updated!
        end

        run_specinfra(:move_file, @temppath, path)
      end

      def action_delete(options)
        if run_specinfra(:check_file_is_file, path)
          run_specinfra(:remove_file, path)
        end
      end
    end
  end
end

