{ config, inputs, ... }:

{
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
      "-L" # print build logs
      "--impure" # using absolute paths in config
    ];
  };

  environment.etc = {
    "flake-output/nixos/config" = {
      source = inputs.self.outPath;
    };
    "flake-output/nixos/flake.lock" = {
      source = builtins.toFile "flake.lock"
        (builtins.readFile "${inputs.self.outPath}/flake.lock");
    };
  };
}
