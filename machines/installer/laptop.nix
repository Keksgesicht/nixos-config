{ config, pkgs, ...}:

{
  imports = [
    ../../hardware/laptop/tuxedo.nix
  ];

  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  services.fwupd.enable = true;
}
