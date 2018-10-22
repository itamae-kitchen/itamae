require 'itamae'

module Itamae
  module Resource
    class File < Base
      define_attribute :action, default: :create
      define_attribute :path, type: String, default_name: true
      define_attribute :content, type: String, default: nil
      define_attribute :mode, type: String
      define_attribute :owner, type: String
      define_attribute :group, type: String
      define_attribute :block, type: Proc, default: proc {}

      def pre_action
        current.exist = run_specinfra(:check_file_is_file, attributes.path)

        case @current_action
        when :create
          attributes.exist = true
        when :delete
          attributes.exist = false
        when :edit
          attributes.exist = true

          if !runner.dry_run? || current.exist
            content = backend.receive_file(attributes.path)
            attributes.block.call(content)
            attributes.content = content
          end
        end

        send_tempfile
        compare_file
      end

      def set_current_attributes
        current.modified = false
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

        if @temppath && @current_action != :delete
          show_content_diff
        end
      end

      def action_create(options)
        if !current.exist && !@temppath
          run_command(["touch", attributes.path])
        end

        change_target = attributes.modified ? @temppath : attributes.path

        if attributes.owner || attributes.group
          run_specinfra(:change_file_owner, change_target, attributes.owner, attributes.group)
        end

        if attributes.mode
          run_specinfra(:change_file_mode, change_target, attributes.mode)
        end

        if attributes.modified
          run_specinfra(:move_file, @temppath, attributes.path)
        end
      end

      def action_delete(options)
        if run_specinfra(:check_file_is_file, attributes.path)
          run_specinfra(:remove_file, attributes.path)
        end
      end

      def action_edit(options)
        change_target = attributes.modified ? @temppath : attributes.path

        if attributes.owner || attributes.group || attributes.modified
          owner = attributes.owner || run_specinfra(:get_file_owner_user, attributes.path).stdout.chomp
          group = attributes.group || run_specinfra(:get_file_owner_group, attributes.path).stdout.chomp
          run_specinfra(:change_file_owner, change_target, owner, group)
        end

        if attributes.mode || attributes.modified
          mode = attributes.mode || run_specinfra(:get_file_mode, attributes.path).stdout.chomp
          run_specinfra(:change_file_mode, change_target, mode)
        end

        if attributes.modified
          run_specinfra(:move_file, @temppath, attributes.path)
        end
      end

      private

      def compare_to
        if current.exist
          attributes.path
        else
          '/dev/null'
        end
      end

      def compare_file
        attributes.modified = false
        unless @temppath
          return
        end

        # When the path currently doesn't exist yet, :change_file_xxx should be performed against `@temppath`.
        # Checking that by `diff -q /dev/null xxx` doesn't work when xxx's content is "", because /dev/null's content is also "".
        if !current.exist && attributes.exist
          attributes.modified = true
          return
        end

        case run_command(["diff", "-q", compare_to, @temppath], error: false).exit_status
        when 1
          # diff found
          attributes.modified = true
        when 2
          # error
          raise Itamae::Backend::CommandExecutionError, "diff command exited with 2"
        end
      end

      def show_content_diff
        if attributes.modified
          Itamae.logger.info "diff:"
          diff = run_command(["diff", "-u", compare_to, @temppath], error: false)
          diff.stdout.each_line do |line|
            color = if line.start_with?('+')
                      :green
                    elsif line.start_with?('-')
                      :red
                    else
                      :clear
                    end
            Itamae.logger.color(color) do
              Itamae.logger.info line.chomp
            end
          end
          runner.handler.event(:file_content_changed, diff: diff.stdout)
        else
          # no change
          Itamae.logger.debug "file content will not change"
        end
      end

      # will be overridden
      def content_file
        nil
      end

      def send_tempfile
        if !attributes.content && !content_file
          @temppath = nil
          return
        end

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

          if backend.is_a?(Itamae::Backend::Docker)
            run_command(["mkdir", @temppath])
            backend.send_file(src, @temppath)
            @temppath = ::File.join(@temppath, ::File.basename(src))
          else
            run_command(["touch", @temppath])
            run_specinfra(:change_file_mode, @temppath, '0600')
            backend.send_file(src, @temppath)
          end

          run_specinfra(:change_file_mode, @temppath, '0600')
        ensure
          f.unlink if f
        end
      end
    end
  end
end
