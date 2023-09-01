{ config, ... }:

{
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
    randomizedDelaySec = "42min";
    options = "--delete-older-than 42d";
  };
}
