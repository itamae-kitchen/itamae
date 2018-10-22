## Unreleased
[full changelog](https://github.com/itamae-kitchen/itamae/compare/v1.9.13...master)

## v1.9.13
[full changelog](https://github.com/itamae-kitchen/itamae/compare/v1.9.12...v1.9.13)

Bugfixes

- [Fixed. Can not create empty file](https://github.com/itamae-kitchen/itamae/pull/269)

## v1.9.12
[full changelog](https://github.com/itamae-kitchen/itamae/compare/v1.9.11...v1.9.12)

Features

- [jail backend: add support of FreeBSD Jail (`itamae jail`)](https://github.com/itamae-kitchen/itamae/pull/249)

Bugfixes

- [docker backend: Fixed edit action of file resource doesn't work with docker backend](https://github.com/itamae-kitchen/itamae/pull/257)

Improvements

- [Print '(dry-run)' first in dry-run mode](https://github.com/itamae-kitchen/itamae/pull/252)

## v1.9.11

Features

- [docker backend: Support image tagging](https://github.com/itamae-kitchen/itamae/pull/230)
- [docker backend: Support docker_container_create_options](https://github.com/itamae-kitchen/itamae/pull/231)


Bugfixes

- [Fix help subcommand](https://github.com/itamae-kitchen/itamae/pull/235)

## v1.9.10

Features

- [Add depth attribute to git resource](https://github.com/itamae-kitchen/itamae/pull/219)
- [Support force link a direcotory](https://github.com/itamae-kitchen/itamae/pull/229)
- [Add support password authentication for ssh](https://github.com/itamae-kitchen/itamae/pull/227)

Bugfixes

- [Run a resource subscribing a resource in child recipe](https://github.com/itamae-kitchen/itamae/pull/224)
- [Change file owner first, then change file permissions](https://github.com/itamae-kitchen/itamae/pull/228)

Improvements

- [Dir.exists? is deprecated, use Dir.exist?](https://github.com/itamae-kitchen/itamae/pull/226)

## v1.9.9

Features

- [`itamae ssh` now accepts `--ssh-config` option](https://github.com/itamae-kitchen/itamae/pull/211)
- [Introduce `--login-shell` option](https://github.com/itamae-kitchen/itamae/pull/217)
- [`gem_package` resource has `uninstall` action](https://github.com/itamae-kitchen/itamae/pull/216)

Bugfixes

- [`send_file` fails against docker backend](https://github.com/itamae-kitchen/itamae/pull/215)

## v1.9.8

Bugfixes

- [edit action of file resource: Keep mtime if no change](https://github.com/itamae-kitchen/itamae/pull/212)

## v1.9.7 (pre)

Bugfixes

- [Mark a file as updated in dry-run mode (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/208)
- [Do not surround LF with the ANSI escape sequence (by @daic-h)](https://github.com/itamae-kitchen/itamae/pull/209)

## v1.9.6

Features

- [Introduce `--detailed-exitcode` option. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/206)

Bugfixes

- [If `git rev-list` fails, do `git fetch origin` (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/205)
- [If gid passed to user resource is a String, treat it as group name. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/207)

## v1.9.5

Bugfixes

- [Set mode and owner correctly when file not changed (by @sorah)](https://github.com/itamae-kitchen/itamae/commit/438d79e4ef714f637f8f1cb50b01293e5232340a)
- [Make tempfile unreadable to secure (by @sorah)](https://github.com/itamae-kitchen/itamae/commit/7af1d29fc020e57f3587aace728fbb40e35669cf)
- [Accept any objects as a log message (by @abicky)](https://github.com/itamae-kitchen/itamae/pull/195)

## v1.9.4

Bugfixes

- [Fix a bug that displays inappropriate diff in file deletion (by @takus)](https://github.com/itamae-kitchen/itamae/pull/200)
- [Show diff on edit action of file resource in dry-run mode. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/197)
- [Stop to call `chown --reference` and `chmod --reference` (by @yuichiro-naito)](https://github.com/itamae-kitchen/itamae/pull/193)

## v1.9.3

Improvements

- [Support redirect on http_request resource (by @hico-horiuchi)](https://github.com/itamae-kitchen/itamae/pull/190)
- [Use /bin/bash as default shell if shell is not set (by @hico-horiuchi)](https://github.com/itamae-kitchen/itamae/pull/192)
- [Stop replacing files which are not updated (by @KitaitiMakoto)](https://github.com/itamae-kitchen/itamae/pull/194)

## v1.9.2

Features

- [New option: `options` for `gem_package` resource (by @hico-horiuchi)](https://github.com/itamae-kitchen/itamae/pull/186)

Improvements

- [Execute `vagrant ssh-config` under `Bundler.with_clean_env` (by @hfm)](https://github.com/itamae-kitchen/itamae/pull/188)
- [Specify type of `recursive` option for `git` resource and `force` option for `link` resource (by @k0kubun)](https://github.com/itamae-kitchen/itamae/pull/189)

## v1.9.1

Features

- [Add `get`, `post`, `put`, `delete` and `options` actions to `http_request` resource (by @hico-horiuchi)](https://github.com/itamae-kitchen/itamae/pull/184)

## v1.9.0

Features

- [New resource: `http_request` resource (by @hico-horiuchi)](https://github.com/itamae-kitchen/itamae/pull/180)
- [Introduce Handler which handles events from Itamae (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/181)
  - Compatibility can be broken because this is experimental feature

Improvements

- [Optimize `git` resource for fixed revision (by @k0kubun)](https://github.com/itamae-kitchen/itamae/pull/182)
- Rename `--dot` option to `--recipe-graph` option. (by @ryotarai)
  - Compatibility can be broken because this is experimental feature

## v1.8.0

Features

- [`generate` and `destroy` subcommands to manipulate cookbooks and roles (by @k0kubun)](https://github.com/itamae-kitchen/itamae/pull/176)

Improvements

- [Fallback to autoload resource plugin (by @k0kubun)](https://github.com/itamae-kitchen/itamae/pull/179)

## v1.7.0

No change

## v1.7.0.pre

Features

- `--profile` option (by @ryotarai)
  - `--profile PATH` saves executed commands to `PATH` in JSON format
  - Compatibility can be broken because this is experimental feature

Bugfixes

- [Suppress errors of `edit` action of `file` resource when the target file doesn't exist in `dry-run` mode (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/144)

## v1.6.3

Features

- [New command: `itamae init` which creates files and directories following the best practices (by @hmadison)](https://github.com/itamae-kitchen/itamae/pull/172)

## v1.6.2

Bugfixes

- [Treat recipe name, arg of `include_recipe`, including `::` twice or more properly (by @sue445)](https://github.com/itamae-kitchen/itamae/pull/171)

## v1.6.1

Bugfixes

- [Send a notification from `edit` action of `file` resource properly (by @kurochan)](https://github.com/itamae-kitchen/itamae/pull/169)

## v1.6.0

Improvements

- [Ignore `--node-yaml` when the result is false (by @k0kubun)](https://github.com/itamae-kitchen/itamae/pull/165)
- [Allow `include_recipe` to omit `.rb` extension (by @k0kubun)](https://github.com/itamae-kitchen/itamae/pull/166)
  - This is backward-compatible change
- [Allow `load_recipes` to load plugin recipes directly (by @k0kubun)](https://github.com/itamae-kitchen/itamae/pull/167)

## v1.5.2

Improvements

- [`include_recipe 'plugin_name'` loads `itamae/plugin/recipe/plugin_name/default.rb` too (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/162)

## v1.5.1

Improvements

- [Logger can be injected one which doesn't have `color` method. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/commit/7c50f376f69029836047f26ab0a46b41b928c0d3)

## v1.5.0

Improvements

- [Make a logger injectable from outside of Itamae. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/160)

## v1.4.5

Improvements

- [Load `default.rb` if `include_recipe` is called with directory path. (by @Rudolph-Miller)](https://github.com/itamae-kitchen/itamae/pull/156)

## v1.4.4

Features

- `--shell` option for `local`, `ssh` and `docker` subcommands. If it is set, it will be used instead of /bin/sh (by @ryotarai)

## v1.4.3

Bugfixes

- [Restore original attributes of a resource after each action. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/commit/28d33da3cb67c6a7635e47845b0055cb17df53a8)

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

- `create` action of `file` resource without `content` attribute changes mode and owner without touching the content of the file (by @ryotarai)

## v1.3.5

Improvements

- [`create` action of `file` resource without `content` attribute changes mode and owner without touching the content of the file (by @ryotarai)](https://github.com/itamae-kitchen/itamae/compare/itamae-kitchen:d4a0abc...itamae-kitchen:3eae144)

Bugfixes

- [Edit action of file resource should set owner and mode if specified (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/143)

## v1.3.4

Improvements

- [Output stdout/err logs during command execution (by @ryotarai)](https://github.com/itamae-kitchen/itamae/commit/24f140dd9744f30c645422959a6a72b6e31eacc4)

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

- Update `HOME` environment variable when `user` attribute is specified. (incompatible change) (by @ryotarai)

## v1.2.21

Improvements

- [Show error message when specified action is unavailable in dry_run mode (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/137)
- [Fix deprecation warnings in unit tests (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/138)

## v1.2.20

Improvements

- [Wrap host inventory value with Hashie::Mash to access it by a method call (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/135)

## v1.2.19

Features

- [`create_home` attribute of user resource (by @xibbar)](https://github.com/itamae-kitchen/itamae/pull/131)

## v1.2.18

Features

- `run_command` method in a recipe, definition and resource (by @ryotarai)

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

- "edit" action of "file" resource (by @ryotarai)

## v1.2.13

Features

- [Add "shell" attribute to user resource (by @toritori0318)](https://github.com/itamae-kitchen/itamae/pull/120)

## v1.2.12

Bugfixes

- Run delayed notifications created by a delayed notification. (by @ryotarai)
- Set updated false after executing resources. (by @ryotarai)

## v1.2.11

Bugfixes

- [Show difference of user resource when it is created. by @gongo](https://github.com/itamae-kitchen/itamae/pull/118)

## v1.2.10

Bugfixes

- [Use given attribute value even if it's falsey (by @sorah)](https://github.com/itamae-kitchen/itamae/pull/117)

## v1.2.9

Bugfixes

- Do not use local variable named `variables`. (by @ryotarai)

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

- Remove code for debugging... (by @ryotarai)

## v1.2.5

Bugfixes

- Bugs in definition feature. (by @ryotarai)

## v1.2.4

Improvements

- Use specinfra/core instead of specinfra. (by @ryotarai)

## v1.2.3

Bugfixes

- Bugs in Node class (by @ryotarai)

## v1.2.2

Improvements

- Refactor Backend and Runner class for multi backends. (by @ryotarai)

## v1.2.1

(yanked)

## v1.2.0

Feature

- Docker backend (by @ryotarai)
  - This backend builds a Docker image.
  - Usage: `itamae docker --image baseimage recipe.rb`
  - NOTE: This feature is experimental.
  - Compatibility can be broken because this is experimental feature

## v1.1.26

Bugfix

- Always outdent. (by @ryotarai)

## v1.1.25

Improvements

- Make logging less verbose by default. (by @eagletmt)
- Change indent width from 3 to 2. (by @ryotarai)

## v1.1.24

Bugfixes

- Make `node` accessible from define block. (by @ryotarai)

## v1.1.23

Feature

- Validate node attributes by `Node#validate!` (by @ryotarai)

## v1.1.22

Improvements

- `source :auto` accepts a template without .erb extension. (by @ryotarai)

## v1.1.21

Bugfixes

- Ignore CommandExecutionError during listing installed gems. (by @eagletmt)
  - because `gem` command may not be installed in dry-run mode

## v1.1.20

Features

- `source :auto` of remote_file and template resources. (by @ryotarai)
  - details: https://github.com/itamae-kitchen/itamae/issues/94

## v1.1.19

Features

- `verify` attribute
  - command will be executed after running resource action. (by @ryotarai)
  - If it fails, Itamae will abort (notifications will not be executed)

Improvements

- [`--vagrant` option without `--host` assumes the VM name `default` (by @muratayusuke)](https://github.com/itamae-kitchen/itamae/pull/91)
- `delayed` is a valid notification timing. (by @ryotarai)
  - same as Chef
- If invalid notification timing is provided, an error will be raised. (by @ryotarai)

## v1.1.18

Improvements

- [Add remove action to package resource (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/92)
- Colorize diff output of file resource (by @ryotarai)
  - removed lines in red
  - inserted lines in green

## v1.1.17

Bugfixes

- Do not remove space char in output of diff. (by @ryotarai)

## v1.1.16

Features

- `source` attribute of `gem_package` resource. (by @ryotarai)

## v1.1.15

Features

- Implement `gem_package` resource. (by @ryotarai)

## v1.1.14

Improvements

- Start a service only if the service is not running. (by @ryotarai)
- Stop a service only if the service is running. (by @ryotarai)

## v1.1.13

Improvements

- [Set executed attr of execute resource for logging purpose. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/86)
- [Colorize diff output of file resource green. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/87)

## v1.1.12

Bugfixes

- [Update home directory of user resource if changed. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/commit/0b5ad5245af8a7849d36d0598f06b7adb9ac025a)

## v1.1.11

Bugfixes

- [Do not include recipes which are already included. (by @ryotarai)](https://github.com/itamae-kitchen/itamae/pull/85)
    - This may break backward compatibility.

## v1.1.10

Feature

- `--dot` option to write dependency graph of recipes
  - Compatibility can be broken because this is experimental feature

## v1.1.9

Improvements

- Show template file path when rendering the template fails. (by @ryotarai)

## v1.1.8

Improvements

- [Show differences in green (by @mizzy)](https://github.com/itamae-kitchen/itamae/pull/82)

## v1.1.7

Bugfixes

- Fix a typo bug (by @ryotarai)

## v1.1.6 (yanked)

Improvements

- [Normalize mode value of file resource by prepending '0' (by @sorah)](https://github.com/itamae-kitchen/itamae/pull/76)

Bugfixes

- [Fix a problem that occurs when the current value is false. (by @mizzy)](https://github.com/itamae-kitchen/itamae/pull/75)

## v1.1.5

Bugfixes

- Clear current attributes before each action. (by @ryotarai)
- Turn on updated-flag after each action. (by @ryotarai)

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

- `user` resource accepts group name (String) as its `gid`. (by @ryotarai)

## v1.1.1

Features

- New resource `remote_directory` which transfers a directory from local to remote like `remote_file` resource. (by @k0kubun)
  - https://github.com/itamae-kitchen/itamae/pull/66

## v1.1.0

Incompatible changes

- [`uid` and `gid` attributes of `user` resource accept only Integer. (by @eagletmt)](https://github.com/itamae-kitchen/itamae/pull/65)
