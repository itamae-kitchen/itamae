require 'itamae'

module Itamae
  module Resource
    class Git < Base
      DEPLOY_BRANCH = "deploy"

      define_attribute :action, default: :sync
      define_attribute :destination, type: String, default_name: true
      define_attribute :repository, type: String, required: true
      define_attribute :revision, type: String
      define_attribute :recursive, type: [TrueClass, FalseClass], default: false
      define_attribute :depth, type: Integer

      def pre_action
        case @current_action
        when :sync
          attributes.exist = true
        end
      end

      def set_current_attributes
        current.exist = run_specinfra(:check_file_is_directory, attributes.destination)
      end

      def action_sync(options)
        ensure_git_available

        new_repository = false

        if check_empty_dir
          cmd = ['git', 'clone']
          cmd << '--recursive' if attributes.recursive
          cmd += ['--depth', attributes.depth.to_s] if attributes.depth
          cmd << attributes.repository << attributes.destination
          run_command(cmd)
          new_repository = true
        end

        target = if attributes.revision
                   get_revision(attributes.revision)
                 else
                   fetch_origin!
                   run_command_in_repo("git ls-remote origin HEAD | cut -f1").stdout.strip
                 end

        if new_repository || target != get_revision('HEAD')
          updated!

          deploy_old_created = false
          if current_branch == DEPLOY_BRANCH
            run_command_in_repo("git branch -m deploy-old")
            deploy_old_created = true
          end

          fetch_origin!
          run_command_in_repo(["git", "checkout", target, "-b", DEPLOY_BRANCH])

          if deploy_old_created
            run_command_in_repo("git branch -d deploy-old")
          end
        end
      end

      private
      def ensure_git_available
        unless run_command("which git", error: false).exit_status == 0
          raise "`git` command is not available. Please install git."
        end
      end

      def check_empty_dir
        run_command("test -z \"$(ls -A #{shell_escape(attributes.destination)})\"", error: false).success?
      end

      def run_command_in_repo(*args)
        unless args.last.is_a?(Hash)
          args << {}
        end
        args.last[:cwd] = attributes.destination
        run_command(*args)
      end

      def current_branch
        run_command_in_repo("git rev-parse --abbrev-ref HEAD").stdout.strip
      end

      def get_revision(branch)
        result = run_command_in_repo("git rev-list #{shell_escape(branch)}", error: false)
        unless result.exit_status == 0
          fetch_origin!
        end
        run_command_in_repo("git rev-list #{shell_escape(branch)}").stdout.lines.first.strip
      end

      def fetch_origin!
        return if @origin_fetched
        @origin_fetched = true
        run_command_in_repo(['git', 'fetch', 'origin'])
      end
    end
  end
end

