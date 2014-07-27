package do
  action :install
  name "git"
end

file do
  action :create
  source node['file_source']
  path "/home/vagrant/foo"
end

directory do
  action :create
  path '/tmp/lightchef'
  mode '0777'
  owner 'vagrant'
  group 'vagrant'
end

