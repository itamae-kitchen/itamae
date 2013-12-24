# Lightchef [![Build Status](https://travis-ci.org/ryotarai/lightchef.png?branch=master)](https://travis-ci.org/ryotarai/lightchef)

Configuration management tool like Chef which is simpler and lighter than Chef

## Concept

* Lighter than Chef
* It's just like Chef. No compatibility.
* No idempotence
* DSL like Chef
* Without compilation
  * All code in recipes will be executed when they are evaluated.
  * To write recipes easier
* Use Ohai
* No role, environment and cookbook

### Examples of Recipes

```ruby
resource "name" do
  action :action
  property "value"
end
```

### Usage

```
$ sudo lightchef execute -j example/node.json example/recipe.rb
D, [2013-12-24T14:05:50.859587 #7156] DEBUG -- : Loading node data from /vagrant/example/node.json ...
I, [2013-12-24T14:05:50.862072 #7156]  INFO -- : >>> Executing Lightchef::Resources::Package ({:action=>:install, :name=>"git"})...
D, [2013-12-24T14:05:51.335070 #7156] DEBUG -- : Command `apt-get -y install git` succeeded
D, [2013-12-24T14:05:51.335251 #7156] DEBUG -- : STDOUT> Reading package lists...
Building dependency tree...
Reading state information...
git is already the newest version.
0 upgraded, 0 newly installed, 0 to remove and 156 not upgraded.
D, [2013-12-24T14:05:51.335464 #7156] DEBUG -- : STDERR>
I, [2013-12-24T14:05:51.335531 #7156]  INFO -- : <<< Succeeded.
I, [2013-12-24T14:05:51.335728 #7156]  INFO -- : >>> Executing Lightchef::Resources::File ({:action=>:create, :source=>"foo", :path=>"/home/vagrant/foo"})...
D, [2013-12-24T14:05:51.335842 #7156] DEBUG -- : Copying a file from '/vagrant/example/foo' to '/home/vagrant/foo'...
I, [2013-12-24T14:05:51.339119 #7156]  INFO -- : <<< Succeeded.
```

### TODO

* `notifies`, `subscribes`

### Future release

* Run via SSH too (thanks to specinfra)
  * Create system info collector instead of Ohai, Facter (They can't execute via SSH)

## Installation

Add this line to your application's Gemfile:

    gem 'lightchef'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lightchef

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
