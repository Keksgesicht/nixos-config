{ config, pkgs, lib
, username, home-dir
, ssd-mnt, secrets-dir
, ... }:

let
  #secrets-pkg = (pkgs.callPackage ../packages/my-secrets.nix {});
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

  # The following cannot work, as the initrd-nixos-activation.service operates on /sysroot
  # and not in the initramfs. Thus, an already mounted directory in /sysroot is required.
  # Luckily, /sysroot/mnt/main is mounted directly before this service.
  /*
  boot.initrd.extraFiles = {
    "${secrets-dir}/local/passwd/${username}" = {
      source = "${secrets-pkg}/passwd/${username}";
    };
  };
  boot.initrd.secrets = {
    "${user-pw-path}" = "${user-pw-path}";
  };
  */
}
