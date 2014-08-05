package "git" do
  action :install
end

remote_file '/home/vagrant/foo' do
  source node['file_source']
end

directory '/tmp/itamae' do
  action :create
  mode '0777'
  owner 'vagrant'
  group 'vagrant'
end

