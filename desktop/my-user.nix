{ config, pkgs, lib
, username, home-dir
, ssd-mnt, secrets-dir
, ... }:

let
  user-pw-path = "${secrets-dir}/keys/passwd/${username}";
in
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
    hashedPasswordFile = "${ssd-mnt}${user-pw-path}";
  };

  users.groups."${username}" = {
    gid = 1000;
  };
}
