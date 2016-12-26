require 'itamae'

module Itamae
  module Resource
    class RemoteDirectory < Base
      define_attribute :action, default: :create
      define_attribute :path, type: String, default_name: true
      define_attribute :source, type: String, required: true
      define_attribute :mode, type: String
      define_attribute :owner, type: String
      define_attribute :group, type: String
      define_attribute :recursive_mode, type: [TrueClass, FalseClass], default: false
      define_attribute :recursive_owner, type: [TrueClass, FalseClass], default: false

      def pre_action
        directory = ::File.expand_path(attributes.source, ::File.dirname(@recipe.path))
        src = ::File.expand_path(directory, ::File.dirname(@recipe.path))

        @temppath = ::File.join(runner.tmpdir, Time.now.to_f.to_s)
        backend.send_directory(src, @temppath)

        case @current_action
        when :create
          attributes.exist = true
        end
      end

      def set_current_attributes
        current.exist = run_specinfra(:check_file_is_directory, attributes.path)

        if current.exist
          current.mode  = run_specinfra(:get_file_mode, attributes.path).stdout.chomp
          current.owner = run_specinfra(:get_file_owner_user, attributes.path).stdout.chomp
          current.group = run_specinfra(:get_file_owner_group, attributes.path).stdout.chomp
        else
          current.mode  = nil
          current.owner = nil
          current.group = nil
        end
      end

      def show_differences
        super

        if current.exist
          diff = run_command(["diff", "-u", attributes.path, @temppath], error: false)
          if diff.exit_status == 0
            # no change
            Itamae.logger.debug "directory content will not change"
          else
            Itamae.logger.info "diff:"
            diff.stdout.each_line do |line|
              Itamae.logger.info "#{line.strip}"
            end
          end
        end
      end

      def action_create(options)
        if attributes.mode
          run_specinfra(:change_file_mode, @temppath, attributes.mode, recursive: attributes.recursive_mode)
        end
        if attributes.owner || attributes.group
          run_specinfra(:change_file_owner, @temppath, attributes.owner, attributes.group, recursive: attributes.recursive_owner)
        end

        if run_specinfra(:check_file_is_file, attributes.path)
          unless check_command(["diff", "-q", @temppath, attributes.path])
            updated!
          end
        else
          updated!
        end

        run_specinfra(:remove_file, attributes.path)
        run_specinfra(:move_file, @temppath, attributes.path)
      end

      def action_delete(options)
        if run_specinfra(:check_file_is_directory, attributes.path)
          run_specinfra(:remove_file, attributes.path)
        end
      end
    end
  end
end
