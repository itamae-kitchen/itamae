package 'dstat' do
  action :install
end

package 'sl'

remote_file "/tmp/remote_file" do
  source "hello.txt"
end

directory "/tmp/directory" do
  mode "0700"
  owner "vagrant"
  group "vagrant"
end

template "/tmp/template" do
  source "hello.erb"
end

file "/tmp/file" do
  content "Hello World"
end



