# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provision :shell, inline: <<-EOC
cat /etc/apt/sources.list | sed -e 's|http://[^ ]*|mirror://mirrors.ubuntu.com/mirrors.txt|g' > /tmp/sources.list
if !(diff -q /etc/apt/sources.list /tmp/sources.list); then
  mv /tmp/sources.list /etc/apt/sources.list
  apt-get update
fi

apt-get -y install ruby2.0 ruby2.0-dev git
(gem2.0 list | grep -q 'bundler ') || gem2.0 install bundler
cd /vagrant
sudo -u vagrant bundle install
bundle exec bin/lightchef execute -j example/node.json example/recipe.rb
  EOC
end
