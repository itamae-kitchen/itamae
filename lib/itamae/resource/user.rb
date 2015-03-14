require 'itamae'
require 'open-uri'

module Itamae
  module Resource
    class User < Base
      define_attribute :action, default: :create
      define_attribute :username, type: String, default_name: true
      define_attribute :gid, type: [Integer, String]
      define_attribute :home, type: String
      define_attribute :password, type: String
      define_attribute :system_user, type: [TrueClass, FalseClass]
      define_attribute :uid, type: Integer
      define_attribute :ssh_import_github, type: String

      def pre_action
        case @current_action
        when :create
          if attributes.ssh_import_github
            begin
              f = Tempfile.open('itamae')
              f.write(ssh_keys_from_github)
              f.close
              @temppath = ::File.join(runner.tmpdir, Time.now.to_f.to_s)
              send_file(f.path, @temppath)
            ensure
              f.unlink if f
            end
          end
        end
      end

      def set_current_attributes
        current.exist = exist?

        if current.exist
          current.uid = run_specinfra(:get_user_uid, attributes.username).stdout.strip.to_i
          current.gid = run_specinfra(:get_user_gid, attributes.username).stdout.strip.to_i
          current.home = run_specinfra(:get_user_home_directory, attributes.username).stdout.strip
          current.password = current_password
        end
      end

      def action_create(options)
        if run_specinfra(:check_user_exists, attributes.username)
          if attributes.uid && attributes.uid != current.uid
            run_specinfra(:update_user_uid, attributes.username, attributes.uid)
            updated!
          end

          if attributes.gid && attributes.gid != current.gid
            run_specinfra(:update_user_gid, attributes.username, attributes.gid)
            updated!
          end

          if attributes.password && attributes.password != current.password
            run_specinfra(:update_user_encrypted_password, attributes.username, attributes.password)
            updated!
          end

          if attributes.home && attributes.home != current.home
            run_specinfra(:update_user_home_directory, attributes.username, attributes.home)
            updated!
          end
        else
          options = {
            gid:            attributes.gid,
            home_directory: attributes.home,
            password:       attributes.password,
            system_user:    attributes.system_user,
            uid:            attributes.uid,
          }

          run_specinfra(:add_user, attributes.username, options)

          updated!
        end

        if attributes.ssh_import_github
          if !run_specinfra(:check_file_is_directory, dot_ssh_path)
            run_specinfra(:create_file_as_directory, dot_ssh_path)
            run_specinfra(:change_file_mode, dot_ssh_path, "0700")
            run_specinfra(:change_file_owner, dot_ssh_path, attributes.username, attributes.username)
          end
          if !run_specinfra(:check_file_is_file, ssh_keys_path) or
             !check_command(["diff", "-q", @temppath, ssh_keys_path])
            run_specinfra(:move_file, @temppath, ssh_keys_path)
            run_specinfra(:change_file_mode, ssh_keys_path, "0600")
            run_specinfra(:change_file_owner, ssh_keys_path, attributes.username, attributes.username)

            updated!
          end
        end
      end

      private
      def exist?
        run_specinfra(:check_user_exists, attributes.username)
      end

      def current_password
        result = run_specinfra(:get_user_encrypted_password, attributes.username)
        if result.success?
          result.stdout.strip
        else
          nil
        end
      end

      def dot_ssh_path
        if @dot_ssh_path
          @dot_ssh_path
        else
          home = current.home || run_specinfra(:get_user_home_directory, attributes.username).stdout.strip
          @dot_ssh_path = ::File.expand_path(".ssh", home)
        end
      end

      def ssh_keys_path
        @ssh_key_path ||= ::File.expand_path("authorized_keys", dot_ssh_path)
      end

      def ssh_keys_from_github
        @ssh_keys_from_github ||= open("https://github.com/#{attributes.ssh_import_github}.keys").read
      end
    end
  end
end

