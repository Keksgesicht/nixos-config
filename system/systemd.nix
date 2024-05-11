# file: system/systemd.nix
# desc: changes to systemd, journald, resolved
{ config, ... }:

{
  # desktop / server
  services.journald.extraConfig =
    if (config.networking.hostName == "cookieclicker") then
      ''
      SystemMaxUse=4G
      SystemdKeepFree=16G
      SystemMaxFiles=512
      ''
    else if (config.networking.hostName == "cookiethinker") then
      ''
      SystemMaxUse=2G
      SystemdKeepFree=8G
      SystemMaxFiles=512
      ''
    else
      ''
      SystemMaxUse=1G
      SystemdKeepFree=4G
      SystemMaxFiles=64
      ''
  ;
}
