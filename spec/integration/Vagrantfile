# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :trusty do |c|
    c.vm.box = "ubuntu/trusty64"

    c.vm.provision :shell, inline: <<-EOC
cat /etc/apt/sources.list | sed -e 's|http://[^ ]*|mirror://mirrors.ubuntu.com/mirrors.txt|g' > /tmp/sources.list
if !(diff -q /etc/apt/sources.list /tmp/sources.list); then
  mv /tmp/sources.list /etc/apt/sources.list
  apt-get update
fi
    EOC
  end
end
