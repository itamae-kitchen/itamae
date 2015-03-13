require 'itamae'

module Itamae
  module Resource
    class File < Base
      define_attribute :action, default: :create
      define_attribute :path, type: String, default_name: true
      define_attribute :content, type: String, default: ''
      define_attribute :mode, type: String
      define_attribute :owner, type: String
      define_attribute :group, type: String

      def pre_action
        begin
          src = if content_file
                  content_file
                else
                  f = Tempfile.open('itamae')
                  f.write(attributes.content)
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
          attributes.exist = true
        end
      end

      def set_current_attributes
        current.exist = run_specinfra(:check_file_is_file, attributes.path)

        if current.exist
          current.mode = run_specinfra(:get_file_mode, attributes.path).stdout.chomp
          current.owner = run_specinfra(:get_file_owner_user, attributes.path).stdout.chomp
          current.group = run_specinfra(:get_file_owner_group, attributes.path).stdout.chomp
        else
          current.mode = nil
          current.owner = nil
          current.group = nil
        end
      end

      def show_differences
        current.mode    = current.mode.rjust(4, '0') if current.mode
        attributes.mode = attributes.mode.rjust(4, '0') if attributes.mode

        super

        if current.exist
          show_file_diff
        end
      end

      def action_create(options)
        if attributes.mode
          run_specinfra(:change_file_mode, @temppath, attributes.mode)
        end
        if attributes.owner || attributes.group
          run_specinfra(:change_file_owner, @temppath, attributes.owner, attributes.group)
        end

        if run_specinfra(:check_file_is_file, attributes.path)
          unless check_command(["diff", "-q", @temppath, attributes.path])
            # the file is modified
            updated!
          end
        else
          # new file
          updated!
        end

        run_specinfra(:move_file, @temppath, attributes.path)
      end

      def action_delete(options)
        if run_specinfra(:check_file_is_file, attributes.path)
          run_specinfra(:remove_file, attributes.path)
        end
      end

      def show_file_diff
        diff = run_command(["diff", "-u", attributes.path, @temppath], error: false)
        if diff.exit_status == 0
          # no change
          Logger.debug "file content will not change"
        else
          Logger.info "diff:"
          diff.stdout.each_line do |line|
            color = if line.start_with?('+')
                      :green
                    elsif line.start_with?('-')
                      :red
                    else
                      :clear
                    end
            Logger.formatter.color(color) do
              Logger.info line.chomp
            end
          end
        end
      end

      # will be overridden
      def content_file
        nil
      end
    end
  end
end

