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

