{ config, pkgs, lib, system, ... }:

let
  pkgsAllowedUnfree = [
    pkgs.corefonts
    pkgs.steamPackages.steam
  ];

  my-functions = (import ./my-functions.nix lib);
in
with my-functions;
{
  nixpkgs = {
    # allow packages with closed source code or paid products
    config.allowUnfreePredicate = (pkg: builtins.elem
      (lib.getName pkg)
      (forEach pkgsAllowedUnfree (x: lib.getName x))
    );
    # set hardware architecture and os platform
    hostPlatform = {
      inherit system;
    };
  };

  nix = {
    # https://search.nixos.org/options?query=nix.daemon*
    # make system useable during (re)build
    daemonCPUSchedPolicy =
      if (config.services.xserver.enable) then "idle"
      else "batch";
    daemonIOSchedClass =
      if (config.services.xserver.enable) then "idle"
      else "best-effort";
    daemonIOSchedPriority =
      if (config.services.xserver.enable) then 7
      else 3;

    # dublicates by creating hardlinks for matching files
    # $AUTH nix-store --optimise
    settings.auto-optimise-store = true;

    # enable flake commands
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
