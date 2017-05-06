#
# this resource defines a group of repos with defaults
#
#
define gitolite::repos (
  $defaults = {},
  $repos    = {},
) {

  ensure_resources('gitolite::repo', $repos, $defaults)

}

