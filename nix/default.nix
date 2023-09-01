# file: nix/nix.nix
# desc: basic settings for nix tools itself

{ config, pkgs, ... }:

{
  imports = [
    ./auto-update.nix
    ./garbage-collect.nix
  ];

  # allow packages with closed source code or paid products
  nixpkgs.config.allowUnfree = true;

  nix = {
    # https://discord.com/channels/@me/998534079425286214/1135687806459584662
    # make system useable during (re)build
    daemonCPUSchedPolicy =
      if (config.services.xserver.enable) then "idle"
      else "other";
    daemonIOSchedClass =
      if (config.services.xserver.enable) then "idle"
      else "best-effort";
    daemonIOSchedPriority =
      if (config.services.xserver.enable) then 6
      else 3;

    # https://discord.com/channels/@me/998534079425286214/1135859766376267886
    # "könnte ordentlich festplattenspeicher sparen" ~Moritz
    # $AUTH nix-store --optimise
    settings.auto-optimise-store = true;

    # enable flake commands
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
}
