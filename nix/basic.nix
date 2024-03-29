{ config, lib, system, ... }:

let
  inherit (lib) types;
in
{
  # set hardware architecture and os platform
  nixpkgs.hostPlatform = {
    inherit system;
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

  # running out of space when building larger projects
  # e.g. chromium for robotnix
  # run `nix build` with `--keep-failed` and do this:
  #   $AUTH mkdir -p /var/tmp/nix-daemon
  #   $AUTH rsync -avHAX --remove-source-files /tmp/nix-daemon/ /var/tmp/nix-daemon/
  #   $AUTH mount --bind /var/tmp/nix-daemon /tmp/nix-daemon
  systemd = {
    services.nix-daemon.environment.TMPDIR = "/tmp/nix-daemon";
    tmpfiles.rules = [ "q /tmp/nix-daemon 1777 root root 10d" ];
  };
}
