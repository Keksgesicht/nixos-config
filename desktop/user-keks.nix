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
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPassword =
      if (config.networking.hostName == "cookieclicker") then
        (lib.removeSuffix "\n" (builtins.readFile "/etc/nixos/secrets/keys/passwd/keks"))
      else null;
  };
  users.groups."keks" = {
    gid = 1000;
  };
}
