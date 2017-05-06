#
# this resource defines a group of users with defaults
#
#
define gitolite::users (
  $defaults = {},
  $users    = {},
) {

  ensure_resources('gitolite::user', $users, $defaults)

}

