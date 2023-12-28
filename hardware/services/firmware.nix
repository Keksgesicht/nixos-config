# https://nixos.wiki/wiki/Fwupd

{ config, ... }:

{
  # firmware update
  services.fwupd = {
    enable = true;
    #extraRemotes = [];
    #EspLocation = /boot;
  };
}
