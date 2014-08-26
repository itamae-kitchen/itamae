# Itamae [![Gem Version](https://badge.fury.io/rb/itamae.svg)](http://badge.fury.io/rb/itamae) [![wercker status](https://app.wercker.com/status/d44df82d2f4529ff664f32fa54ce12f5/s/master "wercker status")](https://app.wercker.com/project/bykey/d44df82d2f4529ff664f32fa54ce12f5)

Simple and lightweight configuration management tool inspired by Chef.

## Concept

- Chef-like DSL
- Simpler and lighter weight than Chef
- Not compatible with Chef
- Idempotent

## Installation

```
$ gem install itamae
```

## Usage

### Run locally

```
$ sudo itamae execute -j example/node.json example/recipe.rb
D, [2013-12-24T14:05:50.859587 #7156] DEBUG -- : Loading node data from /vagrant/example/node.json ...
I, [2013-12-24T14:05:50.862072 #7156]  INFO -- : >>> Executing Itamae::Resource::Package ({:action=>:install, :name=>"git"})...
D, [2013-12-24T14:05:51.335070 #7156] DEBUG -- : Command `apt-get -y install git` succeeded
D, [2013-12-24T14:05:51.335251 #7156] DEBUG -- : STDOUT> Reading package lists...
Building dependency tree...
Reading state information...
git is already the newest version.
0 upgraded, 0 newly installed, 0 to remove and 156 not upgraded.
D, [2013-12-24T14:05:51.335464 #7156] DEBUG -- : STDERR>
I, [2013-12-24T14:05:51.335531 #7156]  INFO -- : <<< Succeeded.
I, [2013-12-24T14:05:51.335728 #7156]  INFO -- : >>> Executing Itamae::Resource::File ({:action=>:create, :source=>"foo", :path=>"/home/vagrant/foo"})...
D, [2013-12-24T14:05:51.335842 #7156] DEBUG -- : Copying a file from '/vagrant/example/foo' to '/home/vagrant/foo'...
I, [2013-12-24T14:05:51.339119 #7156]  INFO -- : <<< Succeeded.
```

### Run via SSH

```
$ itamae ssh -j example/node.json -h 192.168.10.10 -p 22 -u user -i /path/to/private_key example/recipe.rb
```

## Recipes

You can write recipes like Chef's one.

```ruby
package "dstat" do
  action :install
end
```

Further example is here: [spec/integration/recipes/default.rb](spec/integration/recipes/default.rb)

## Doc

https://github.com/ryotarai/itamae/wiki

## Run tests

Requirements: Vagrant

```
$ bundle exec rake spec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

