include_recipe "./included.rb"

# TODO: replace with user resource
execute 'id itamae || useradd itamae'

######

package 'dstat' do
  action :install
end

package 'sl' do
  version '3.03-17'
end

######

execute "echo -n > /tmp/notifies"

execute "echo -n 1 >> /tmp/notifies" do
  action :nothing
end

execute "echo -n 2 >> /tmp/notifies" do
  notifies :run, "execute[echo -n 1 >> /tmp/notifies]"
end

execute "echo -n 3 >> /tmp/notifies" do
  action :nothing
end

execute "echo -n 4 >> /tmp/notifies" do
  notifies :run, "execute[echo -n 3 >> /tmp/notifies]", :immediately
end

######

execute "echo -n > /tmp/subscribes"

execute "echo -n 1 >> /tmp/subscribes" do
  action :nothing
  subscribes :run, "execute[echo -n 2 >> /tmp/subscribes]"
end

execute "echo -n 2 >> /tmp/subscribes"

execute "echo -n 3 >> /tmp/subscribes" do
  action :nothing
  subscribes :run, "execute[echo -n 4 >> /tmp/subscribes]", :immediately
end

execute "echo -n 4 >> /tmp/subscribes"

######

remote_file "/tmp/remote_file" do
  source "hello.txt"
end

directory "/tmp/directory" do
  mode "700"
  owner "itamae"
  group "itamae"
end

template "/tmp/template" do
  source "hello.erb"
end

file "/tmp/file" do
  content "Hello World"
  mode "777"
end

execute "echo 'Hello Execute' > /tmp/execute"

file "/tmp/never_exist1" do
  only_if "exit 1"
end

file "/tmp/never_exist2" do
  not_if "exit 0"
end

######

service "cron" do
  action :stop
end

execute "ps -C cron > /tmp/cron_stopped; true"

service "cron" do
  action :start
end

execute "ps -C cron > /tmp/cron_running; true"

######

package "nginx"

service "nginx" do
  action [:enable, :start]
end

execute "test -f /etc/rc3.d/S20nginx" # test
execute "test $(ps h -C nginx | wc -l) -gt 0" # test

service "nginx" do
  action [:disable, :stop]
end

execute "test ! -f /etc/rc3.d/S20nginx" # test
execute "test $(ps h -C nginx | wc -l) -eq 0" # test

######

link "/tmp-link" do
  to "/tmp"
end

#####

local_ruby_block "greeting" do
  block do
    Itamae::Logger.info "板前"
  end
end

#####

package "git"

git "/tmp/git_repo" do
  repository "https://github.com/ryotarai/infrataster.git"
  revision "v0.1.0"
end

#####

execute "echo Hello > /tmp/created_by_itamae_user" do
  user "itamae"
end

