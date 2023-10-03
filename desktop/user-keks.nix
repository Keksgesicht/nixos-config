{ config, pkgs, ...}:

{
  # Define a user account.
  # Don't forget to set a password with ‘passwd’.
  users.users.keks = {
    isNormalUser = true;
    description = "Jan B.";
    shell = pkgs.zsh;
    uid = 1000;
    group = "keks";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
  users.groups.keks = {
    gid = 1000;
  };
}
