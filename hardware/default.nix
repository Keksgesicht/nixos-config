{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages =
    if (config.services.xserver.enable) then
      pkgs.linuxPackages_latest
    else
      pkgs.linuxPackages;
}
