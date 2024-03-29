# 
# this resources defines a git user
# you also can use it to define values for a group of
# repositories (by using an @ in front of the group name)
#
# @param user
#   the user name
#   defaults to $title
# @param keys
#   array of users ssh keys
# @param key_source 
#   a puppet source to fetch key from
# @param comments
#   an array of comments to add to this section
#   defaults to []
# @param groups
#   an array of groups to append the user to
#   the group names can be prefix with an @ sign
#   (if they are puppet take care of)
#   defaults to []
# @param order 
#   string, to order the repos
#   $order will be prefixed with 30 for the grouping section
#   and 20 for the user section.
#   defaults to ''
#
define gitolite::user (
  String                 $user        = $title,
  Array                  $keys        = [],
  Optional[String[1]]    $key_source  = undef,
  Array                  $groups      = [],
  Variant[Array, String] $comments    = [],
  String                 $order       = '', # lint:ignore:params_empty_string_assignment
) {
  include gitolite

  # create the key from source (only one key currently ...)
  if $key_source {
    file { "${gitolite::userhome}/.puppet_userkeys/${user}":
      source => $key_source,
      notify => Exec['gitolite update user keys from source'],
    }
  }

  # create the keys from the keys array
  $keys.each | $k, $key | {
    file { "${gitolite::keydir}/${user}@${k}.pub":
      content => $key,
      notify  => $gitolite::exec_update,
    }
  }

  if $groups != [] {
    $members = $user
    concat::fragment { "gitolite_conffile groups (user) ${title}":
      target  => $gitolite::conffile,
      content => template('gitolite/groups.erb'),
      order   => "40${order}",
    }
  }
}
