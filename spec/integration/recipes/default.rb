node.reverse_merge!({
  message: "Hello, Itamae"
})

execute 'apt-get update'

include_recipe "./included.rb"
include_recipe "./included.rb" # including the same recipe is expected to be skipped.

user "create itamae user" do
  uid 123
  username "itamae"
  password "$1$ltOY8bZv$iZ57f1KAp8jwKViNm3pze."
  home '/home/foo'
end

user "update itamae user" do
  uid 1234
  username "itamae"
  password "$1$TQz9gPMl$nHYrsA5W2ZdZ0Yn021BQH1"
  home '/home/itamae'
end

######

package 'dstat' do
  action :install
end

package 'sl' do
  version '3.03-17'
end

package 'resolvconf' do
  action :remove
end

######

package "ruby"

gem_package 'tzinfo' do
  version '1.1.0'
end

gem_package 'tzinfo' do
  version '1.2.2'
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

remote_file "/tmp/remote_file_auto" do
  source :auto
end

######

directory "/tmp/directory" do
  mode "700"
  owner "itamae"
  group "itamae"
end

template "/tmp/template" do
  source "hello.erb"
  variables goodbye: "Good bye"
end

template "/tmp/template_auto" do
  source :auto
  variables goodbye: "Good bye"
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

package "nginx" do
  options "--force-yes"
end

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

#####

execute "echo 'notify to resource in default2.rb'" do
  notifies :create, "file[put file in default2.rb]"
end

#####

file "/tmp/never_exist3" do
  action :create
end

file "/tmp/never_exist3" do
  action :delete
end

#####

include_recipe "define/default.rb"

definition_example "name" do
  key 'value'
end

#####

file "/tmp/never_exist4" do
  action :nothing
end

file "/tmp/file1" do
  content "Hello, World"
end

file "/tmp/file1" do
  content "Hello, World"
  notifies :create, "file[/tmp/never_exist4]"
end

#####

execute 'true' do
  verify 'true'
end

