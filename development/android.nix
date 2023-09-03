{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    # https://nixos.wiki/wiki/WayDroid#Clipboard_sharing
    wl-clipboard
  ];

  # enable Android Debugging Bridge (ADB)
  programs.adb.enable = true;
  #users.users.keks.extraGroups = [ "adbusers" ];

  # https://nixos.wiki/wiki/WayDroid
  virtualisation.waydroid.enable = true;
}
