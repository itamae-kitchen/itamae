# TODO: Send patches to Specinfra

Specinfra::Command::Base::User.class_eval do
  class << self
    def update_home_directory(user, directory)
      # -m: Move the content of the user's home directory to the new location.
      "usermod -m -d #{escape(directory)} #{escape(user)}"
    end
  end
end

module Specinfra::Backend
  class Docker < Exec
    def initialize
      begin
        require 'docker' unless defined?(::Docker)
      rescue LoadError
        fail "Docker client library is not available. Try installing `docker-api' gem."
      end

      ::Docker.url = Specinfra.configuration.docker_url

      if image = Specinfra.configuration.docker_image
        @images = []
        @base_image = get_or_pull_image(image)

        create_and_start_container
        ObjectSpace.define_finalizer(self, proc { cleanup_container })
      elsif container = Specinfra.configuration.docker_container
        @container = ::Docker::Container.get(container)
      else
        fail 'Please specify docker_image or docker_container.'
      end
    end

    def commit_container
      @container.commit
    end

    private
    def get_or_pull_image(name)
      begin
        ::Docker::Image.get(name)
      rescue ::Docker::Error::NotFoundError
        ::Docker::Image.create('fromImage' => name)
      end
    end

    def create_and_start_container
      opts = { 'Image' => current_image.id }

      if current_image.json["Config"]["Cmd"].nil?
        opts.merge!({'Cmd' => ['/bin/sh']})
      end

      opts.merge!({'OpenStdin' => true})

      if path = Specinfra.configuration.path
        (opts['Env'] ||= []) << "PATH=#{path}"
      end

      env = Specinfra.configuration.env.to_a.map { |v| v.join('=') }
      opts['Env'] = opts['Env'].to_a.concat(env)

      opts.merge!(Specinfra.configuration.docker_container_create_options || {})

      @container = ::Docker::Container.create(opts)
      @container.start
    end
  end
end

