# 
# this resources define a git repository
# you also can use them to define values for a group of
# repositories (by using an @ in front of the group name)
#
# @param repos
#   an array of repos (or a group of repos ( @blah )
#   defaults to [ $title ]
# @param comments
#   an array of comments to add defaults to []
# @param rules
#   an array of rules.
#   a rule has three elements:
#   permission, refex and user/group
#   a hash of permissions:
#   [{ 'RW+' => 'username'}, ... ]
# @param options
# @param configs
# @param add_configs
#   additional configs, merged with configs
# @param groups
#   an array of groups to append the repos to
#   the group names can be prefixed with an @ sign
#   (if they are puppet take care of)
# @param order
#   string, to order the repos
#   $order will be prefixed with 60 for the grouping section
#   and 90 for the repo section.
#   defaults to ''
# @param description
#   a description to add to the repo
# @param hooks
#   hooks to install
# @param group
# @param remotes
#   Hash of remote repos to sync branches and tags from
#   defaults to {}
#   Example:
#   'upstream' => {
#     'url' => 'https://github.com/openstack/puppet-nova'
#     'fetches' => [
#       'master:master',
#       'refs/tags/*:refs/tags/*',
#       'refs/heads/stable/*:refs/heads/stable/*',
#     ]
#   }
#   will update the master branch, all tags and all branches stable/*
#   from the remote location mentioned in url.
#
#   To remove an upstream you can set ensure to 'absent'
#   You can set more than one repo to sync from, but it's up to you
#   to ensure that no conflicts occur !
# @param remote_option
#   additional options to add when fetching the remotes.
#   Defaults to '', example add '-v' for verbose output.
#
define gitolite::repo (
  Array  $repos                     = [$title],
  Variant[String, Array]  $comments = [],
  Hash   $rules                     = {},
  Hash   $options                   = {},
  Hash   $configs                   = {},
  Hash   $add_configs               = {},
  Array  $groups                    = [],
  String $order                     = '',
  String $description               = '',
  Hash   $hooks                     = {},
  String $group                     = 'root',
  Hash   $remotes                   = {},
  String $remote_option             = '',
) {

  include ::gitolite

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
      tag     => ['gitolite-repo'],
    }
  }

  file { "${gitolite::reporoot}/${title}.git/hooks":
    ensure  => 'directory',
    mode    => '0700',
    owner   => $gitolite::user,
    group   => $group,
    purge   => true,
    recurse => true,
    tag     => ['gitolite-repo'],
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
    gitremote{"remote for ${title} ${thename}":
      ensure     => pick($rem['ensure'], 'present'),
      remotename => $thename,
      directory  => "${gitolite::reporoot}/${title}.git",
      confowner  => $gitolite::user,
      url        => $rem['url'],
      fetches    => $rem['fetches'],
    }

    if pick($rem['ensure'], 'present') != 'absent' {
      concat::fragment{ "gitolite upgrade-repos.sh: ${title} ${$thename}":
        target  => "${gitolite::userhome}/upgrade-repos.sh",
        content => "su ${gitolite::user} -c 'git -C ${gitolite::reporoot}/${title}.git fetch ${remote_option} ${thename}'\n",
        order   => md5("${title}_${thename}"),
      }
    }
  }
}
