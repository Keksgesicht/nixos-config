# file: system/systemd.nix
# desc: changes to systemd, journald, resolved

{ config, pkgs, lib, ...}:

{
  # desktop / server
  services.journald.extraConfig =
    if (config.networking.hostName == "cookieclicker") then
      ''
      SystemMaxUse=8G
      #SystemdKeepFree=16G
      SystemMaxFiles=256
      ''
    else if (config.networking.hostName == "cookiethinker") then
      ''
      SystemMaxUse=4G
      #SystemdKeepFree=16G
      SystemMaxFiles=128
      ''
    else
      ''
      SystemMaxUse=2G
      #SystemdKeepFree=4G
      SystemMaxFiles=64
      ''
  ;
}
