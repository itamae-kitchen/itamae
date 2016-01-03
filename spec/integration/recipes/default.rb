node.reverse_merge!({
  message: "Hello, Itamae"
})

execute 'apt-get update'
execute 'deluser --remove-home itamae2' do
  only_if "id itamae2"
end

include_recipe "./included.rb"
include_recipe "./included.rb" # including the same recipe is expected to be skipped.

user "create itamae user" do
  uid 123
  username "itamae"
  password "$1$ltOY8bZv$iZ57f1KAp8jwKViNm3pze."
  home '/home/foo'
  shell '/bin/sh'
end

user "update itamae user" do
  uid 1234
  username "itamae"
  password "$1$TQz9gPMl$nHYrsA5W2ZdZ0Yn021BQH1"
  home '/home/itamae'
  shell '/bin/dash'
end

directory "/home/itamae" do
  mode "755"
  owner "itamae"
  group "itamae"
end

user "create itamae2 user with create home directory" do
  username "itamae2"
  create_home true
  home "/home/itamae2"
  shell "/bin/sh"
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

gem_package 'bundler' do
  options ['--no-ri', '--no-rdoc']
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

directory "/tmp/directory_never_exist1" do
  action :create
end

directory "/tmp/directory_never_exist1" do
  action :delete
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

http_request "/tmp/http_request.html" do
  url "https://httpbin.org/get?from=itamae"
end

http_request "/tmp/http_request_delete.html" do
  action :delete
  url "https://httpbin.org/delete?from=itamae"
end

http_request "/tmp/http_request_post.html" do
  action :post
  message "love=sushi"
  url "https://httpbin.org/post?from=itamae"
end

http_request "/tmp/http_request_put.html" do
  action :put
  message "love=sushi"
  url "https://httpbin.org/put?from=itamae"
end

http_request "/tmp/http_request_headers.html" do
  headers "User-Agent" => "Itamae"
  url "https://httpbin.org/get"
end

http_request "/tmp/http_request_redirect.html" do
  redirect_limit 1
  url "https://httpbin.org/redirect-to?url=https%3A%2F%2Fhttpbin.org%2Fget%3Ffrom%3Ditamae"
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

execute "touch /tmp-link-force"
link "/tmp-link-force" do
  to "/tmp"
  force true
end

#####

local_ruby_block "greeting" do
  block do
    Itamae.logger.info "板前"
  end
end

#####

package "git"

git "/tmp/git_repo" do
  repository "https://github.com/ryotarai/infrataster.git"
  revision "v0.1.0"
end

git "/tmp/git_repo_submodule" do
  repository "https://github.com/mmasaki/fake_repo_including_submodule.git"
  recursive true
end

#####

execute "echo -n \"$HOME\n$(pwd)\" > /tmp/created_by_itamae_user" do
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

file "/tmp/file_create_without_content" do
  content "Hello, World"
end

file "/tmp/file_create_without_content" do
  owner "itamae"
  group "itamae"
  mode "600"
end

#####

execute 'true' do
  verify 'true'
end

#####

execute 'echo 1 > /tmp/multi_delayed_notifies' do
  notifies :run, "execute[echo 2 >> /tmp/multi_delayed_notifies]"
end

execute 'echo 2 >> /tmp/multi_delayed_notifies' do
  action :nothing
  notifies :run, "execute[echo 3 >> /tmp/multi_delayed_notifies]"
end

execute 'echo 3 >> /tmp/multi_delayed_notifies' do
  action :nothing
  notifies :run, "execute[echo 4 >> /tmp/multi_delayed_notifies]"
end

execute 'echo 4 >> /tmp/multi_delayed_notifies' do
  action :nothing
end

#####

execute 'echo 1 > /tmp/multi_immediately_notifies' do
  notifies :run, "execute[echo 2 >> /tmp/multi_immediately_notifies]", :immediately
end

execute 'echo 2 >> /tmp/multi_immediately_notifies' do
  action :nothing
  notifies :run, "execute[echo 3 >> /tmp/multi_immediately_notifies]", :immediately
end

execute 'echo 3 >> /tmp/multi_immediately_notifies' do
  action :nothing
  notifies :run, "execute[echo 4 >> /tmp/multi_immediately_notifies]", :immediately
end

execute 'echo 4 >> /tmp/multi_immediately_notifies' do
  action :nothing
end

#####

file '/tmp/file_edit_sample' do
  content 'Hello, world'
  owner 'itamae'
  group 'itamae'
  mode '444'
end

file '/tmp/file_edit_sample' do
  action :edit
  owner 'itamae2'
  group 'itamae2'
  mode '400'
  block do |content|
    content.gsub!('world', 'Itamae')
  end
  notifies :run, "execute[echo -n 1 > /tmp/file_edit_notifies]"
end

execute 'echo -n 1 > /tmp/file_edit_notifies' do
  action :nothing
end

###

unless run_command("echo -n Hello").stdout == "Hello"
  raise "run_command in a recipe failed"
end

define :run_command_in_definition do
  unless run_command("echo -n Hello").stdout == "Hello"
    raise "run_command in a definition failed"
  end
end

execute "echo Hello" do
  unless run_command("echo -n Hello").stdout == "Hello"
    raise "run_command in a resource failed"
  end
end

local_ruby_block 'execute run_command' do
  block do
    unless run_command("echo -n Hello").stdout == "Hello"
      raise "run_command in local_ruby_block failed"
    end
  end
end

###

v1 = node.memory.total
v2 = node[:memory][:total]
v3 = node['memory']['total']

unless v1 == v2 && v2 == v3 && v1 =~ /\A\d+kB\z/
  raise "failed to fetch host inventory value (#{v1}, #{v2}, #{v3})"
end
