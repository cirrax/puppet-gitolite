# 
# this resources defines a git repository
# you also can use it to define values for a group of
# repositories (by using an @ in fron of the group name)
#
# parameters:
# $repos
#   an array of repos (or a group of repos ( @blah )
#   defaults to [ $title ]
# $comments
#   an array of comments to add defaults to []
# $rules
#   an array of rules.
#   a rule has three elements:
#   permission, refex and user/group
#   a hash of permissions:
#   [{ 'RW+' => 'username'}, ... ]
# $options     = {},
# $git-configs = {},
# $groups      = [],
# an array of groups to append the repos to
# the group names can be prefix with an @ sign
# (if they are puppet take care of)
# $order
# string, to order the repos
# $order will be prefixed with 60 for the grouping section
# and 90 for the repo section.
# defaults to ''

define gitolite::repo (
  $repos    = [$title],
  $comments = [],
  $rules    = {},
  $options  = {},
  $configs  = {},
  $groups   = [],
  $order    = '',
) {

  include gitolite

  concat::fragment { "gitolite_conffile repo ${title}":
    target  => $::gitolite::conffile,
    content => template('gitolite/repo.erb'),
    order   => "90${order}",
  }

  if $groups != [] {
    $members = $repos
    concat::fragment { "gitolite_conffile groups (repo) ${title}":
      target  => $::gitolite::conffile,
      content => template('gitolite/groups.erb'),
      order   => "60${order}",
    }
  }
}
