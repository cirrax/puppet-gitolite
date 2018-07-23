#
# Generate an SSH authentication key
#
# Key generation for (passwordless) authentication to a
# remote system.
#
# Parameters:
#   $filename:
#     Filename (full path) for the key. Defaults to $title.
#   $type:
#     Type of key, either dsa, ecdsa or rsa. Defaults to rsa.
#   $length:
#     Key length. Defaults to 2048. See man ssh-keygen for restrictions
#     regarding non RSA keys.
#   $password:
#     Password for the key. Defaults to no password. This is not very secure
#     as the password is visible in plain text in the puppet manifest and as a
#     process parameters when creating the key.
#   $comment:
#     Comment describing the Key. Defaults to "Automatic authentication key for $user on $fqdn".
#   $user:
#     User who uses this key. This user must have write access to the directory
#     containing the key. Defaults to "root"
#
class gitolite::ssh_key(
  String  $filename,
  String  $type     = 'rsa',
  Integer $length   = 2048,
  String  $password = '',
  String  $comment  = 'undef',
  String  $user     = 'root',
) {

  if $comment == 'undef' {
    $_comment = "Automatic authentication key for ${user} on ${::fqdn}"
  } else {
    $_comment = $comment
  }

  if $filename == 'undef' {
    $_filename = $title
  } else {
    $_filename = $filename
  }

  exec {"key-${title}":
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    command => "ssh-keygen -t ${type} -b ${length} -C \"${_comment}\" -f ${_filename} -q -N \"${password}\"",
    user    => $user,
    creates => $_filename,
  }
}
