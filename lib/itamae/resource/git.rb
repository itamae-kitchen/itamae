require 'itamae'

module Itamae
  module Resource
    class Git < Base
      DEPLOY_BRANCH = "deploy"

      define_attribute :action, default: :sync
      define_attribute :destination, type: String, default_name: true
      define_attribute :repository, type: String, required: true
      define_attribute :revision, type: String

      def sync_action
        ensure_git_available

        if run_specinfra(:check_file_is_directory, destination)
          run_command_in_repo(['git', 'fetch', 'origin'])
        else
          run_command(['git', 'clone', repository, destination])
        end

        target_revision =
          revision ||
          run_command_in_repo("git ls-remote origin HEAD | cut -f1").stdout.strip

        deploy_old_created = false
        if current_branch == DEPLOY_BRANCH
          run_command_in_repo("git branch -m deploy-old")
          deploy_old_created = true
        end

        run_command_in_repo(["git", "checkout", target_revision, "-b", DEPLOY_BRANCH])

        if deploy_old_created
          run_command_in_repo("git branch -d deploy-old")
        end
      end

      private
      def ensure_git_available
        unless run_command("which git", error: false).exit_status == 0
          raise "`git` command is not available. Please install git."
        end
      end

      def run_command_in_repo(*args)
        run_command(*args, cwd: destination)
      end

      def current_branch
        run_command_in_repo("git rev-parse --abbrev-ref HEAD").stdout.strip
      end
    end
  end
end

