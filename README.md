# Lightchef

TODO: Write a gem description

## Concept

* Lighter than Chef
* No idempotence
* DSL like Chef
* Without compilation
  * All code in recipes will be executed when they are evaluated.
  * To write recipes easier

### Recipe

```ruby
resource "name" do
  action :action
  property "value"
end
```

### TODO

* `notifies`, `subscribes`

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
