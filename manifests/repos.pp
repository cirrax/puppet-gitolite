#
# this resource defines a group of repos with defaults
#
# @param defaults
#   defaults for all generated repos
# @param repos
#   repos to create see gitolite::repo for parameters
#
define gitolite::repos (
  Hash $defaults = {},
  Hash $repos    = {},
) {
  ensure_resources('gitolite::repo', $repos, $defaults)
}
