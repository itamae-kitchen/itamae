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

execute "echo 'Hello Execute' > /tmp/execute"

file "/tmp/never_exist1" do
  only_if "exit 1"
end

file "/tmp/never_exist2" do
  not_if "exit 0"
end


