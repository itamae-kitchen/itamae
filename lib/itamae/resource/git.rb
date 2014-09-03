require 'itamae'

module Itamae
  module Resource
    class Git < Base
      DEPLOY_BRANCH = "deploy"

      define_attribute :action, default: :sync
      define_attribute :destination, type: String, default_name: true
      define_attribute :repository, type: String, required: true
      define_attribute :revision, type: String

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

        if run_specinfra(:check_file_is_directory, attributes.destination)
          run_command_in_repo(['git', 'fetch', 'origin'])
        else
          run_command(['git', 'clone', attributes.repository, attributes.destination])
          new_repository = true
        end

        target = if attributes.revision
                   get_revision(attributes.revision)
                 else
                   run_command_in_repo("git ls-remote origin HEAD | cut -f1").stdout.strip
                 end

        if new_repository || target != get_revision('HEAD')
          updated!

          deploy_old_created = false
          if current_branch == DEPLOY_BRANCH
            run_command_in_repo("git branch -m deploy-old")
            deploy_old_created = true
          end

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

      def run_command_in_repo(*args)
        run_command(*args, cwd: attributes.destination)
      end

      def current_branch
        run_command_in_repo("git rev-parse --abbrev-ref HEAD").stdout.strip
      end

      def get_revision(branch)
        run_command_in_repo("git rev-list #{shell_escape(branch)} | head -n1").stdout.strip
      end
    end
  end
end

