{ config, pkgs, lib, system, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./office
  ]
  ++ lib.optionals (system == "aarch64-linux") [ ./aarch64 ]
  ++ lib.optionals (system == "x86_64-linux") [ ./x86_64 ]
  ;

  boot.kernelPackages =
    if (config.services.xserver.enable) then
      pkgs.linuxPackages_latest
    else
      pkgs.linuxPackages;
}
