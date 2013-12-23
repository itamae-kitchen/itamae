require 'net/scp'

module SpecInfra
  module Backend
    class Exec
      def copy_file(src, dst)
        FileUtils.cp(src, dst)
      end
    end

    class Ssh
      def copy_file(src, dst)
        scp = Net::SCP.new(SpecInfra.configuration.ssh)
        scp.upload!(src, dst)
      end
    end
  end
end

