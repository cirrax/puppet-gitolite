#
# this resource defines a group of users with defaults
#
#
define gitolite::users (
  Hash $defaults = {},
  Hash $users    = {},
) {

  ensure_resources('gitolite::user', $users, $defaults)

}

