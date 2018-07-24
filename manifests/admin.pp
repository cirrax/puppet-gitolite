#
# This class manages the gitolite.conf file
# and prepares to manage the ssh keys with puppet.
#
# do not use this class if you want to use the
# gitolite-admin.git repositoy for these tasks.
# (you have been warned ! if you use it once,
# there is no puppet way back, only manual work
# will get you back)
#
# Parameters:
# $remove_admin_repo:
#   if true (the default) the repository
#   gitoline_admin.git will be removed
# $repos:
#   a hash of repos, to be defined
# $users:
#   a hash of users, to be defined
# $add_testing_repo
#   allow RW+ for all users to the testing repo
#   default: true
#
class gitolite::admin (
  Boolean $remove_admin_repo = true,
  Hash    $repos             = {},
  Hash    $users             = {},
  Boolean $add_testing_repo  = true,
) inherits gitolite {

  include ::gitolite::params

  concat { $::gitolite::conffile:
    ensure => present,
    notify => $::gitolite::exec_update,
  }

  $h = '#####################'
  $default_fragments = {
    'gitolite_conf_main_header' => {
      'content' => "${h}\n# managed with puppet\n\n",
      'order'   => '00',
    },
    'gitolite_conf_user_group_header' => {
      'content' => "${h}\n# users  group section\n\n",
      'order'   => '30',
    },
    'gitolite_conf_repo_group_header' => {
      'content' => "${h}\n# repos group section\n\n",
      'order'   => '50',
    },
    'gitolite_conf_repo_header' => {
      'content' => "${h}\n# repo section\n\n",
      'order'   => '80',
    },
  }
  ensure_resources('concat::fragment', $default_fragments, {'target' => $::gitolite::conffile })

  # manage the keydir: 

  file{ "${::gitolite::userhome}/.puppet_userkeys":
    ensure  => directory,
    force   => true,
    recurse => true,
    purge   => true,
    notify  => Exec['gitolite update user keys from source'],
  }

  $gh=$::gitolite::userhome
  exec{'gitolite update user keys from source':
    command     => "/bin/true ;
rm -rf ${gh}/.puppet_userkeys2 ;
find ${gh}/.puppet_userkeys -type d|sed 's|/\\.puppet_userkeys|/.puppet_userkeys2|'|xargs mkdir ;
(cd ${gh}/.puppet_userkeys; find -type f -exec split -l 1 -a 3 -d --additional-suffix=.pub {} ../.puppet_userkeys2/{}@ \\; ) ;
",
    refreshonly => true,
    before      => File[ $gitolite::keydir ],
    require     => File[ "${::gitolite::userhome}/.puppet_userkeys" ],
  }

  file{ $::gitolite::keydir:
    ensure  => directory,
    force   => true,
    recurse => true,
    purge   => true,
    source  => "${::gitolite::userhome}/.puppet_userkeys2",
    notify  => $::gitolite::exec_update,
  }

  # remove the admin repo since it is not used:
  if $remove_admin_repo {
    file {"${gitolite::reporoot}/gitolite-admin.git":
      ensure => absent,
      force  => true,
      backup => false, # if you used it, you have this localy available, otherwise  it's the default !
    }
  }

  # add testing repo
  if $add_testing_repo {
    gitolite::repo{'testing':
      rules    => { 'RW+' => '@all' },
      comments => ['default for testing repo'],
    }
  }

  # ensure some resources
  ensure_resources('gitolite::repo', $repos)
  ensure_resources('gitolite::user', $users)
}
