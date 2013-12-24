package do
  action :install
  name "git"
end

file do
  action :create
  source node['file_source']
  path "/home/vagrant/foo"
end

