#
# this resource defines a group of users with defaults
#
# @param defaults
#   defaults for all generated users
# @param users
#   users to create see gitolite::user for parameters
#
define gitolite::users (
  Hash $defaults = {},
  Hash $users    = {},
) {
  ensure_resources('gitolite::user', $users, $defaults)
}
