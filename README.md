# Itamae [![Gem Version](https://badge.fury.io/rb/itamae.svg)](http://badge.fury.io/rb/itamae) [![Code Climate](https://codeclimate.com/github/ryotarai/itamae/badges/gpa.svg)](https://codeclimate.com/github/ryotarai/itamae) [![wercker status](https://app.wercker.com/status/d44df82d2f4529ff664f32fa54ce12f5/s/master "wercker status")](https://app.wercker.com/project/bykey/d44df82d2f4529ff664f32fa54ce12f5)

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

## Basic Usage

### Run locally

```
$ sudo itamae execute -j example/node.json recipe.rb
```

### Run via SSH

```
$ itamae ssh -j example/node.json -h 192.168.10.10 -p 22 -u user -i /path/to/private_key recipe.rb
```

#### Vagrant Integration

```
$ itamae ssh -h vagrant_vm_name --vagrant recipe.rb
```

## Recipes

You can write recipes like Chef's one.

```ruby
package "dstat" do
  action :install
end
```

Further example is here: [spec/integration/recipes/default.rb](spec/integration/recipes/default.rb)

## Documentations

https://github.com/ryotarai/itamae/wiki

## Run tests

Requirements: Vagrant

```
$ bundle exec rake spec
```

## Presentations

- [(in Japanese) Itamae - Infra as Code 現状確認会](https://speakerdeck.com/ryotarai/itamae-infra-as-code-xian-zhuang-que-ren-hui)

## Contributing

If you have a problem, please [create an issue](https://github.com/ryotarai/itamae/issues/new) or a pull request.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

