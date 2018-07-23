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
# $configs     = {},
# $add_configs = {},
#   additional configs, merged with configs
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
# $remotes = {}
#   Hash of remote repos to sync
#   

define gitolite::repo (
  Array  $repos       = [$title],
  Array  $comments    = [],
  Hash   $rules       = {},
  Hash   $options     = {},
  Hash   $configs     = {},
  Hash   $add_configs = {},
  Array  $groups      = [],
  String $order       = '',
  String $description = '',
  Hash   $hooks       = {},
  String $group       = 'root',
  Hash   $remotes     = {},
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

  if $description != '' {
    file { "${gitolite::reporoot}/${title}.git/description":
      content => $description,
      owner   => $gitolite::user,
      group   => $group,
    }
  }

  file { "${gitolite::reporoot}/${title}.git/hooks":
    ensure  => 'directory',
    mode    => '0700',
    owner   => $gitolite::user,
    group   => $group,
    purge   => true,
    recurse => true,
  }

  # ensure that the gitolite hook is not overwritten.
  file { "${gitolite::reporoot}/${title}.git/hooks/update":
    ensure => 'link',
    target => "${gitolite::userhome}/.gitolite/hooks/common/update",
    owner  => $gitolite::user,
    group  => $group,
  }

  $hooks.each | $hname, $dest | {
    file { "${gitolite::reporoot}/${title}.git/hooks/${hname}":
      ensure => 'link',
      target => "${gitolite::userhome}/scripts/${dest}",
      owner  => $gitolite::user,
      group  => $group,
    }
  }

  $remotes.each | $thename, $rem | {
    gitremote{$thename:
      ensure    => pick($rem['ensure'], 'present'),
      directory => "${gitolite::reporoot}/${title}.git",
      confowner => $gitolite::user,
      url       => $rem['url'],
      fetches   => $rem['fetches'],
    }

    if pick($rem['ensure'], 'present') != 'absent' {
      concat::fragment{ "gitolite upgrade-repos.sh: ${title} ${$thename}":
        target  => "${gitolite::userhome}/upgrade-repos.sh",
        content => "su ${gitolite::user} -c 'git -C ${gitolite::reporoot}/${title}.git fetch ${thename}'\n",
        order   => md5("${title}_${thename}"),
      }
    }
  }
}
