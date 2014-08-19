package 'dstat' do
  action :install
end

package 'sl'

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
  owner "vagrant"
  group "vagrant"
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

link "/tmp-link" do
  to "/tmp"
end
