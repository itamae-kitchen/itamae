# [![](https://raw.githubusercontent.com/itamae-kitchen/itamae-logos/master/small/FA-Itamae-horizontal-01-180x72.png)](https://github.com/itamae-kitchen/itamae)

[![Gem Version](https://badge.fury.io/rb/itamae.svg)](http://badge.fury.io/rb/itamae) [![Code Climate](https://codeclimate.com/github/ryotarai/itamae/badges/gpa.svg)](https://codeclimate.com/github/ryotarai/itamae) [![Build Status](https://travis-ci.org/itamae-kitchen/itamae.svg?branch=master)](https://travis-ci.org/itamae-kitchen/itamae) [![Slack](https://img.shields.io/badge/slack-join-blue.svg)](https://itamae-slackin.herokuapp.com/)

Simple and lightweight configuration management tool inspired by Chef.

- [CHANGELOG](https://github.com/itamae-kitchen/itamae/blob/master/CHANGELOG.md)

## Concept

- Chef-like DSL (but not compatible with Chef)
- Simpler and lighter weight than Chef
- Only recipes
- Idempotent

## Installation

```
$ gem install itamae
```

## Getting Started

Create a recipe file as `recipe.rb`:

```ruby
package 'nginx' do
  action :install
end

service 'nginx' do
  action [:enable, :start]
end
```

And then excute `itamae` command to apply a recipe to a local machine.

```
$ itamae local recipe.rb
 INFO : Starting Itamae...
 INFO : Recipe: /home/user/recipe.rb
 INFO :    package[nginx]
 INFO :       action: install
 INFO :          installed will change from 'false' to 'true'
 INFO :    service[nginx]
 INFO :       action: enable
 INFO :       action: start
```

Or you can apply a recipe to a remote machine by `itamae ssh`.

```
$ itamae ssh --host host001.example.jp recipe.rb
```

You can also apply a recipe to Vagrant VM by `itamae ssh --vagrant`.

```
$ itamae ssh --vagrant --host vm_name recipe.rb
```

You can find further information to use Itamae on [Itamae Wiki](https://github.com/itamae-kitchen/itamae/wiki).

Enjoy!

## Documentation

https://github.com/itamae-kitchen/itamae/wiki

## Run tests

Requirements: Vagrant

```
$ bundle exec rake spec
```

## Get Involved

- [Join Slack team](https://itamae-slackin.herokuapp.com/)

## Presentations / Articles

### in Japanese

- [Itamae - Infra as Code 現状確認会](https://speakerdeck.com/ryotarai/itamae-infra-as-code-xian-zhuang-que-ren-hui)
- [クックパッドのサーバプロビジョニング事情 - クックパッド開発者ブログ](http://techlife.cookpad.com/entry/2015/05/12/080000)
- [Itamaeが構成管理を仕込みます！ ～新進気鋭の国産・構成管理ツール～：連載｜gihyo.jp … 技術評論社](http://gihyo.jp/admin/serial/01/itamae)


## Contributing

If you have a problem, please [create an issue](https://github.com/itamae-kitchen/itamae/issues/new) or a pull request.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

