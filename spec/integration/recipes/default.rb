package 'dstat' do
  action :install
end

package 'sl'

remote_file "/tmp/file_by_lightchef" do
  source "hello.txt"
end

directory "/tmp/directory_by_lightchef" do
  mode "0700"
  owner "vagrant"
  group "vagrant"
end

template "/tmp/template_by_lightchef" do
  source "hello.erb"
end



