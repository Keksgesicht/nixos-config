{ ... }:

{
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "*-*-5,10,15,20,25,30 01:23:45";
    randomizedDelaySec = "15min";
    options = "--delete-older-than 23d";
  };
}
