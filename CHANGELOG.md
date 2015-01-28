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

