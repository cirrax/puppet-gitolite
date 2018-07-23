#
# this resource defines a group of repos with defaults
#
#
define gitolite::repos (
  Hash $defaults = {},
  Hash $repos    = {},
) {

  ensure_resources('gitolite::repo', $repos, $defaults)

}

