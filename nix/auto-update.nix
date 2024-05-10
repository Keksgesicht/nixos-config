{ config, lib, inputs, ... }:

let
  nixos-cfg-path = "/etc/nixos";
  latest-lock-file = "/nix/var/nix/profiles/system/etc/flake-output/flake.lock";
in
{
  environment.etc = {
    "flake-output/nixos-config" = {
      source = inputs.self.outPath;
    };
    "flake-output/flake.lock" = {
      source = /etc/nixos/flake.lock;
    };
  };

  # https://nixos.wiki/wiki/Automatic_system_upgrades
  system.autoUpgrade = {
    enable = true;
    dates = "*-*-2,4,6,8,12,14,16,18,22,24,26,28 02:22:19";
    randomizedDelaySec = "123min";

    operation =
      if (config.services.xserver.enable) then "boot"
      else "switch";
    allowReboot = !(config.services.xserver.enable);
    rebootWindow = {
      lower = "04:20";
      upper = "05:45";
    };

    flake = inputs.self.outPath;
    flags = [
      "--update-input" "nixpkgs-stable"
      "--update-input" "nixpkgs-unstable"
      "--print-build-logs" # -L
      #"--verbose"         # -v
    ];
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "C+ ${nixos-cfg-path}/flake-latest.lock - - - - ${latest-lock-file}"
  ];
  nix.settings.extra-sandbox-paths = [
    nixos-cfg-path
  ];
}
