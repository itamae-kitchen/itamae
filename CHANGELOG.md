## v1.5.2

Improvements

- [`include_recipe 'plugin_name'` loads `itamae/plugin/recipe/plugin_name/default.rb` too](https://github.com/itamae-kitchen/itamae/pull/162)

## v1.5.1

Improvements

- [Logger can be injected one which doesn't have `color` method.](https://github.com/itamae-kitchen/itamae/commit/7c50f376f69029836047f26ab0a46b41b928c0d3)

## v1.5.0

Improvements

- [Make a logger injectable from outside of Itamae.](https://github.com/itamae-kitchen/itamae/pull/160)

## v1.4.5

Improvements

- [Load `default.rb` if `include_recipe` is called with directory path. (by @Rudolph-Miller)](https://github.com/itamae-kitchen/itamae/pull/156)

## v1.4.4

Features

- `--shell` option for `local`, `ssh` and `docker` subcommands. If it is set, it will be used instead of /bin/sh

## v1.4.3

Bugfixes

- [Restore original attributes of a resource after each action.](https://github.com/itamae-kitchen/itamae/commit/28d33da3cb67c6a7635e47845b0055cb17df53a8)

## v1.4.2

Improvements

- [Load plugin gems that is not managed by bundler. (by @KitaitiMakoto)](https://github.com/itamae-kitchen/itamae/pull/151)

## v1.4.1

Improvements

- [`gem_binary` of `gem_package` resource accepts an Array too. (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/149)
- [`git` resource executes `git clone` if the destination directory is empty (by @tacahilo)](https://github.com/itamae-kitchen/itamae/pull/150)

## v1.4.0

Improvements

- Make `cwd` a common attribute. (idea by @tacahilo)
  - It was an attribute for execute resource
- When `user` attribute is set, change directory to the user's home directory. (idea by @tacahilo)
  - even if cd command fail, it will be ignored
  - directory specified by cwd will take precedence over this

## v1.3.6

Bugfixes

- `create` action of `file` resource without `content` attribute changes mode and owner without touching the content of the file

## v1.3.5

Improvements

- [`create` action of `file` resource without `content` attribute changes mode and owner without touching the content of the file](https://github.com/itamae-kitchen/itamae/compare/itamae-kitchen:d4a0abc...itamae-kitchen:3eae144)

Bugfixes

- [Edit action of file resource should set owner and mode if specified (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/143)

## v1.3.4

Improvements

- [Output stdout/err logs during command execution](https://github.com/itamae-kitchen/itamae/commit/24f140dd9744f30c645422959a6a72b6e31eacc4)

## v1.3.3

Improvements

- [Add `container` option to `docker` subcommand (by @marcy-terui)](https://github.com/itamae-kitchen/itamae/pull/142)

## v1.3.2

Features

- [Add `recursive` attribute to `git` resource (by @mmasaki)](https://github.com/itamae-kitchen/itamae/pull/140)

## v1.3.1

Features

- [Add `delete` action to `directory` resource (by @rrreeeyyy)](https://github.com/itamae-kitchen/itamae/pull/139)

## v1.3.0

Improvements

- Update `HOME` environment variable when `user` attribute is specified. (incompatible change)

## v1.2.21

Improvements

- [Show error message when specified action is unavailable in dry_run mode (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/137)
- [Fix deprecation warnings in unit tests (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/138)

## v1.2.20

Improvements

- [Wrap host inventory value with Hashie::Mash to access it by a method call](https://github.com/itamae-kitchen/itamae/pull/135)

## v1.2.19

Features

- [`create_home` attribute of user resource (by @xibbar)](https://github.com/itamae-kitchen/itamae/pull/131)

## v1.2.18

Features

- `run_command` method in a recipe, definition and resource

## v1.2.17

Features

- [Support provider for service resource (by @sonots)](https://github.com/itamae-kitchen/itamae/pull/134)

## v1.2.16

Improvements

- [`force` option for `link` resource (by @mikeda)](https://github.com/itamae-kitchen/itamae/pull/128)

## v1.2.15

Bugfixes

- [Fix --no-sudo to work properly (by @evalphobia)](https://github.com/itamae-kitchen/itamae/pull/126)
- [Fix a glitch on raising exception when source doesn't exist (by @mozamimy)](https://github.com/itamae-kitchen/itamae/pull/125)

## v1.2.14

Features

- "edit" action of "file" resource

## v1.2.13

Features

- [Add "shell" attribute to user resource (by @toritori0318)](https://github.com/itamae-kitchen/itamae/pull/120)

## v1.2.12

Bugfixes

- Run delayed notifications created by a delayed notification.
- Set updated false after executing resources.

## v1.2.11

Bugfixes

- [Show difference of user resource when it is created. by @gongo](https://github.com/itamae-kitchen/itamae/pull/118)

## v1.2.10

Bugfixes

- [Use given attribute value even if it's falsey (by @sorah)](https://github.com/itamae-kitchen/itamae/pull/117)

## v1.2.9

Bugfixes

- Do not use local variable named `variables`.

If `variables` is used as local variable's name, the following causes a syntax error.

```
template "..." do
  variables foo: bar
  # variables(foo: bar) # This never cause a syntax error
end
```

See also: https://bugs.ruby-lang.org/issues/11016

## v1.2.8

Improvements

- [Load ~/.ssh/config (by @maruware)](https://github.com/itamae-kitchen/itamae/pull/115)

## v1.2.7

Bugfixes

- Backend::Docker#finalize should be public. (by @mizzy)

## v1.2.6

- Remove code for debugging...

## v1.2.5

Bugfixes

- Bugs in definition feature.

## v1.2.4

Improvements

- Use specinfra/core instead of specinfra.

## v1.2.3

Bugfixes

- Bugs in Node class

## v1.2.2

Improvements

- Refactor Backend and Runner class for multi backends.

## v1.2.1

(yanked)

## v1.2.0

Feature

- Docker backend
  - This backend builds a Docker image.
  - Usage: `itamae docker --image baseimage recipe.rb`
  - NOTE: This feature is experimental.

## v1.1.26

Bugfix

- Always outdent.

## v1.1.25

Improvements

- Make logging less verbose by default. (by @eagletmt)
- Change indent width from 3 to 2.

## v1.1.24

Bugfixes

- Make `node` accessible from define block.

## v1.1.23

Feature

- Validate node attributes by `Node#validate!`

## v1.1.22

Improvements

- `source :auto` accepts a template without .erb extention.

## v1.1.21

Bugfixes

- Ignore CommandExecutionError during listing installed gems. (by @eagletmt)
  - because `gem` command may not be installed in dry-run mode

## v1.1.20

Features

- `source :auto` of remote_file and template resources.
  - details: https://github.com/itamae-kitchen/itamae/issues/94

## v1.1.19

Features

- `verify` attribute
  - command will be executed after running resource action.
  - If it fails, Itamae will abort (notifications will not be executed)

Improvements

- [`--vagrant` option without `--host` assumes the VM name `default` (by @muratayusuke)](https://github.com/itamae-kitchen/itamae/pull/91)
- `delayed` is a valid notification timing.
  - same as Chef
- If invalid notification timing is provided, an error will be raised.

## v1.1.18

Improvements

- [Add remove action to package resource (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/92)
- Colorize diff output of file resource
  - removed lines in red
  - inserted lines in green

## v1.1.17

Bugfixes

- Do not remove space char in output of diff.

## v1.1.16

Features

- `source` attribute of `gem_package` resource.

## v1.1.15

Features

- Implement `gem_package` resource.

## v1.1.14

Improvements

- Start a service only if the service is not running.
- Stop a service only if the service is running.

## v1.1.13

Improvements

- [Set executed attr of execute resource for logging purpose.](https://github.com/itamae-kitchen/itamae/pull/86)
- [Colorize diff output of file resource green.](https://github.com/itamae-kitchen/itamae/pull/87)

## v1.1.12

Bugfixes

- [Update home directory of user resource if changed.](https://github.com/itamae-kitchen/itamae/commit/0b5ad5245af8a7849d36d0598f06b7adb9ac025a)

## v1.1.11

Bugfixes

- [Do not include recipes which are already included.](https://github.com/itamae-kitchen/itamae/pull/85)
    - This may break backward compatibility.

## v1.1.10

Feature

- `--dot` option to write dependency graph of recipes (Experimental)

## v1.1.9

Improvements

- Show template file path when rendering the template fails.

## v1.1.8

Improvements

- [Show differences in green (by @mizzy)](https://github.com/itamae-kitchen/itamae/pull/82)

## v1.1.7

Bugfixes

- Fix a typo bug

## v1.1.6 (yanked)

Improvements

- [Normalize mode value of file resource by prepending '0' (by @sorah)](https://github.com/itamae-kitchen/itamae/pull/76)

Bugfixes

- [Fix a problem that occurs when the current value is false. (by @mizzy)](https://github.com/itamae-kitchen/itamae/pull/75)

## v1.1.5

Bugfixes

- Clear current attributes before each action.
- Turn on updated-flag after each action.

## v1.1.4

Bugfixes

- `Node#[]` with unknown key returns nil. (by @nownabe)
  - https://github.com/itamae-kitchen/itamae/pull/71

## v1.1.3

Features

- `group` resource (Thanks to @a2ikm)
  - https://github.com/itamae-kitchen/itamae/pull/70

## v1.1.2

Features

- `user` resource accepts group name (String) as its `gid`.

## v1.1.1

Features

- New resource `remote_directory` which transfers a directory from local to remote like `remote_file` resource. (Thanks to @k0kubun)
  - https://github.com/ryotarai/itamae/pull/66

## v1.1.0

Incompatible changes

- `uid` and `gid` attributes of `user` resource accept only Integer. (https://github.com/ryotarai/itamae/pull/65)
