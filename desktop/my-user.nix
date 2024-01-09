{ config, pkgs, lib
, username, home-dir
, secrets-dir
, ... }:

{
  users.users."${username}" = {
    isNormalUser = true;
    description = "Jan B.";
    shell = pkgs.zsh;
    uid = 1000;
    group = "${username}";
    home = "${home-dir}";
    homeMode = "700";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # Don't forget to create a password with `mkpasswd`.
    hashedPassword = (lib.removeSuffix "\n"
      (builtins.readFile "${secrets-dir}/keys/passwd/${username}")
    );
  };
  users.groups."${username}" = {
    gid = 1000;
  };
}
