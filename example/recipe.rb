package do
  action :install
  name "git"
end

file do
  action :create
  source "foo"
  path "/home/vagrant/foo"
end

