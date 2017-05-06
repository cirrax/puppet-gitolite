#
# params
class gitolite::params (
) {

  case $::osfamily {
    'Debian': {
      $packages            = ['gitolite3']
      $additional_packages = []            # installed with ensure_packages()
    }
    default: {
      fail("${module_name}: Unsupported osfamily: ${::osfamily}")
    }
  }

  $rcfile   = 'gitolite3.rc'
  $conffile = 'gitolite.conf'

}
