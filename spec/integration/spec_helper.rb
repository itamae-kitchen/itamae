require "serverspec"
require "docker"

set :backend, :docker

set :docker_image, ENV["DOCKER_IMAGE"]
set :docker_container, ENV["DOCKER_CONTAINER"]

# Disable sudo
# set :disable_sudo, true

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'

RSpec.configure do |config|
  unless ENV["CI"]
    # focus is enabled only local (Run all specs at CI)
    config.filter_run_when_matching :focus
  end
end
