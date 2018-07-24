# 
# this resources defines a git user
# you also can use it to define values for a group of
# repositories (by using an @ in front of the group name)
#
# parameters:
# $user
#   the user name
#   defaults to $title
# $keys
#   array of users ssh keys
# $key_source 
#   a puppet source to fetch key from
# $comments
#   an array of comments to add to this section
#   defaults to []
# $groups
#   an array of groups to append the user to
#   the group names can be prefix with an @ sign
#   (if they are puppet take care of)
#   defaults to []
# $order 
#   string, to order the repos
#   $order will be prefixed with 30 for the grouping section
#   and 20 for the user section.
#   defaults to ''

define gitolite::user (
  String $user        = $title,
  Array  $keys        = [],
  String $key_source  = '',
  Array  $groups      = [],
  Variant[Array, String]  $comments    = [],
  String $order       = '',
){

  include ::gitolite

  # create the key from source (only one key currently ...)
  if $key_source != '' {
    file { "${::gitolite::userhome}/.puppet_userkeys/${user}":
      source => $key_source,
      notify => Exec['gitolite update user keys from source' ],
    }
  }

  # create the keys from the keys array
  $keys.each | $k, $key | {
    file { "${::gitolite::keydir}/${user}@${k}.pub":
      content => $key,
      notify  => $::gitolite::exec_update,
    }
  }

  if $groups != [] {
    $members = $user
    concat::fragment { "gitolite_conffile groups (user) ${title}":
      target  => $::gitolite::conffile,
      content => template('gitolite/groups.erb'),
      order   => "40${order}",
    }
  }

}
