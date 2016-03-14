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
      end

      def set_current_attributes
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
          compare_file
        end
      end

      def action_create(options)
        if !current.exist && !@temppath
          run_command(["touch", attributes.path])
        end

        if @temppath
          if run_specinfra(:check_file_is_file, attributes.path)
            unless check_command(["diff", "-q", @temppath, attributes.path])
              # the file is modified
              updated!
            end
          else
            # new file
            updated!
          end
        end

        change_target = @temppath && updated?  ? @temppath : attributes.path

        if attributes.mode
          run_specinfra(:change_file_mode, change_target, attributes.mode)
        end

        if attributes.owner || attributes.group
          run_specinfra(:change_file_owner, change_target, attributes.owner, attributes.group)
        end

        if @temppath && updated?
          run_specinfra(:move_file, @temppath, attributes.path)
        end
      end

      def action_delete(options)
        if run_specinfra(:check_file_is_file, attributes.path)
          run_specinfra(:remove_file, attributes.path)
        end
      end

      def action_edit(options)
        if attributes.mode
          run_specinfra(:change_file_mode, @temppath, attributes.mode)
        else
          mode = run_specinfra(:get_file_mode, attributes.path).stdout.chomp
          run_specinfra(:change_file_mode, @temppath, mode)
        end

        if attributes.owner || attributes.group
          run_specinfra(:change_file_owner, @temppath, attributes.owner, attributes.group)
        else
          owner = run_specinfra(:get_file_owner_user, attributes.path).stdout.chomp
          group = run_specinfra(:get_file_owner_group, attributes.path).stdout.chomp
          run_specinfra(:change_file_owner, @temppath, owner)
          run_specinfra(:change_file_group, @temppath, group)
        end

        unless check_command(["diff", "-q", @temppath, attributes.path])
          # the file is modified
          updated!
        end

        run_specinfra(:move_file, @temppath, attributes.path)
      end

      private

      def compare_file
        compare_to = if current.exist
                       attributes.path
                     else
                       '/dev/null'
                     end

        diff = run_command(["diff", "-u", compare_to, @temppath], error: false)
        if diff.exit_status == 0
          # no change
          Itamae.logger.debug "file content will not change"
        else
          Itamae.logger.info "diff:"
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

          run_command(["touch", @temppath])
          run_specinfra(:change_file_mode, @temppath, '0600')
          backend.send_file(src, @temppath)
          run_specinfra(:change_file_mode, @temppath, '0600')
        ensure
          f.unlink if f
        end
      end
    end
  end
end
