{ config, pkgs, lib, ... }:

{
  # Define a user account.
  # Don't forget to set a password with ‘passwd’.
  users.users."keks" = {
    isNormalUser = true;
    description = "Jan B.";
    shell = pkgs.zsh;
    uid = 1000;
    group = "keks";
    home = "/home/keks";
    homeMode = "700";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPassword = (lib.removeSuffix "\n"
      (builtins.readFile "/etc/nixos/secrets/keys/passwd/keks")
    );
  };
  users.groups."keks" = {
    gid = 1000;
  };
}
