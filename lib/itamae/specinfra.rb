require 'specinfra'
 
# TODO: move to specinfra
 
module Itamae
  def self.backend=(backend)
    @backend = backend
  end

  def self.backend
    @backend
  end

  def self.create_local_backend
    create_backend(:exec)
  end

  def self.create_ssh_backend(options)
    Specinfra.configuration.request_pty = true

    Specinfra.configuration.host = options.delete(:host)
    Specinfra.configuration.ssh_options = options
    create_backend(:ssh)
  end

  private
  def self.create_backend(type)
    Specinfra.configuration.backend = type
    Itamae.backend = Specinfra.backend
  end

  module SpecinfraHelpers
    module RunCommand
      def backend
        Itamae.backend
      end

      def run_command(cmd)
        backend.run_command(cmd)
      end
    end
  end
end

