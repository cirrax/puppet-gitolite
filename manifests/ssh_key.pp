#
# Generate an SSH authentication key
#
# Key generation for (passwordless) authentication to a
# remote system.
#
# @param filename
#   Filename (full path) for the key. Required.
# @param type
#   Type of key, either dsa, ecdsa or rsa. Defaults to rsa.
# @param length
#   Key length. Defaults to 2048. See man ssh-keygen for restrictions
#   regarding non RSA keys.
# @param password
#   Password for the key. Defaults to no password. This is not very secure
#   as the password is visible in plain text in the puppet manifest and as a
#   process parameters when creating the key.
# @param comment
#   Comment describing the Key. Defaults to "Automatic authentication key for $user on $fqdn".
# @param user
#   User who uses this key. This user must have write access to the directory
#   containing the key. Defaults to "root"
#
class gitolite::ssh_key (
  String              $filename,
  String              $type     = 'rsa',
  Integer             $length   = 2048,
  String              $password = '', # lint:ignore:params_empty_string_assignment
  Optional[String[1]] $comment  = undef,
  String              $user     = 'root',
) {
  if $comment {
    $_comment = "Automatic authentication key for ${user} on ${facts['networking']['fqdn']}"
  } else {
    $_comment = $comment
  }

  exec { 'key for gitolite':
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    command => "ssh-keygen -t ${type} -b ${length} -C \"${_comment}\" -f ${filename} -q -N \"${password}\"",
    user    => $user,
    creates => $filename,
  }
}
