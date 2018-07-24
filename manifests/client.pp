# 
# Class to install git
#
class gitolite::client {
  ensure_packages(['git'])
}

