require 'serverspec'
require 'net/ssh'
require 'tempfile'

set :backend, :ssh

def vagrant(cmd)
  Bundler.with_clean_env do
    env = {"VAGRANT_CWD" => File.dirname(__FILE__)}
    system env, "/usr/bin/vagrant #{cmd}"
  end
end

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['TARGET_HOST']

config = Tempfile.new('', Dir.tmpdir)
vagrant "ssh-config #{host} > #{config.path}"

options = Net::SSH::Config.for(host, [config.path])

options[:user] ||= Etc.getlogin

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'

