{ config, pkgs, lib, inputs, username, ... }:

let
  secrets-pkg = (pkgs.callPackage ../packages/my-secrets.nix {});
  git-repo = lib.removeSuffix "\n" (
    builtins.readFile "${secrets-pkg}/git-repo.txt"
  );
  latest-system-cfg-dir = "/nix/var/nix/profiles/system/etc/flake-output/nixos-config";
in
{
  environment.etc = {
    "flake-output/my-secrets" = {
      source = secrets-pkg;
    };
    "flake-output/nixos-config" = {
      source = inputs.self.outPath;
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
    "r  ${git-repo}/flake.lock - - - - -"
    "C+ ${git-repo}/flake.lock - - - - ${latest-system-cfg-dir}/flake.lock"
    "Z  ${git-repo}/flake.lock 0644 ${username} ${username} - -"
  ];
}
