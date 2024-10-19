{ secrets-pkg, ... }:

let
  keyPathClient = secrets-pkg + "/ssh/client";
in
{
  # allow remote backups
  users.users."root".openssh.authorizedKeys.keyFiles = [
    (keyPathClient + "/id_backup.pub")
  ];
}
