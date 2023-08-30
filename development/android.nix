{ config, pkgs, ...}:

{
  # enable Android Debugging Bridge (ADB)
  programs.adb.enable = true;
  #users.users.keks.extraGroups = [ "adbusers" ];
}
