# gitolite puppet module


#### Table of Contents

1. [Overview](#overview)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Contribuiting](#contributing)


## Overview

This module is used to configure gitolite and to configure git repositories and permissions.


## Usage

To start using gitolite you need to include the gitolite main class.

A minimal example might be:

~~~
class{'gitolite':
  user     => 'gitolite',
  userhome => '/srv/gitolite',
}
~~~

The gitolite::admin class is only used if you like to do all admin work through
puppet (like create new repos, users and permissions).
If gitolite::admin is not included, you can use the admin git repo to do these tasks (feature of gitolite).

## Reference

Find documentation about possible parameters on top of each manifest.
Also see [REFERENCE.md](REFERENCE.md)

### classes

#### gitolite
The main class to install and configure gitolite.

#### gitolite::admin
This class manages the gitolite.conf file
and prepares to manage the ssh keys with puppet.

Use this class if you want to do all admin work through puppet
(add users, repositories and permissions)

do not use this class if you want to use the
gitolite-admin.git repositoy for these tasks.
(you have been warned ! if you use it once,
there is no puppet way back, only manual work
will get you back)

#### gitolite::client
Install the git package.

#### gitolite::ssh_key
Generate an SSH authentication key for authentication
to a remote system (eg. for git hooks).

#### gitolite::params
System specific parameters.


### defined types

#### gitolite::repo
Define git repositories

#### gitolite::repos
Define several git repositories with merged default values.

#### gitolite::user
This resources defines a git user

#### gitolite::users
Define several git users with merged default values.


## Contributing

Please report bugs and feature request using GitHub issue tracker.

For pull requests, it is very much appreciated to check your Puppet manifest with puppet-lint
and the available spec tests  in order to follow the recommended Puppet style guidelines
from the Puppet Labs style guide.

### Authors

This module is mainly written by [Cirrax GmbH](https://cirrax.com).

See the [list of contributors](https://github.com/cirrax/puppet-gitolite/graphs/contributors)
for a list of all contributors.
