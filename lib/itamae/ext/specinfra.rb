# TODO: Send patches to Specinfra

module Specinfra
  module Backend
    class Base
      def receive_file(from, to = nil)
        raise NotImplementedError
      end
    end

    class Exec < Base
      def receive_file(from, to = nil)
        if to
          FileUtils.cp(from, to)
        else
          ::File.read(from)
        end
      end
    end

    class Docker < Exec
      def receive_file(from, to = nil)
        if to
          send_file(from, to)
        else
          run_command("cat #{from}").stdout
        end
      end
    end

    class Ssh < Exec
      def receive_file(from, to = nil)
        scp_download!(from, to)
      end

      private

      def scp_download!(from, to, opt={})
        if get_config(:scp).nil?
          set_config(:scp, create_scp)
        end

        scp = get_config(:scp)
        scp.download!(from, to, opt)
      end
    end
  end
end

