package 'sl' do
  version '5.02-1'
end

######

gem_package 'ast' do
  version '2.0.0'
  options ['--no-document']
  cwd '/tmp'
end

######

package "cron"

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

execute "systemctl --quiet is-enabled nginx" # test
execute "test $(ps h -C nginx | wc -l) -gt 0" # test

service "nginx" do
  action [:disable, :stop]
end

execute "! systemctl --quiet is-enabled nginx" # test
execute "test $(ps h -C nginx | wc -l) -eq 0" # test
