{ config, ... }:

{
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "*-*-3,6,9,12,15,18,21,24,27,30 01:23:45";
    randomizedDelaySec = "23min";
    options = "--delete-older-than 23d";
  };
}
