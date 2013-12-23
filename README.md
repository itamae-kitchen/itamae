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
$ sudo lightchef execute example/recipe.rb
I, [2013-12-23T07:12:19.044094 #1691]  INFO -- : >>> Executing Lightchef::Resources::Package ({:action=>:install, :name=>"git"})...
D, [2013-12-23T07:12:19.500203 #1691] DEBUG -- : Command `apt-get -y install git` succeeded
D, [2013-12-23T07:12:19.500365 #1691] DEBUG -- : STDOUT> Reading package lists...
Building dependency tree...
Reading state information...
git is already the newest version.
0 upgraded, 0 newly installed, 0 to remove and 156 not upgraded.
D, [2013-12-23T07:12:19.500571 #1691] DEBUG -- : STDERR>
I, [2013-12-23T07:12:19.500631 #1691]  INFO -- : <<< Succeeded.
I, [2013-12-23T07:12:19.501097 #1691]  INFO -- : >>> Executing Lightchef::Resources::File ({:action=>:create, :source=>"foo", :path=>"/home/vagrant/foo"})...
D, [2013-12-23T07:12:19.501496 #1691] DEBUG -- : Copying a file from '/vagrant/example/foo' to '/home/vagrant/foo'...
I, [2013-12-23T07:12:19.503977 #1691]  INFO -- : <<< Succeeded.
```

### TODO

* `notifies`, `subscribes`

### Future release

* Run via SSH too (thanks to specinfra)
  * Create system info collector instead of Ohai (Ohai can't execute via SSH)

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
