{ pkgs, lib, ... }:

let
  fc-bin = "${pkgs.lm_sensors}/sbin/fancontrol";
  fc-cfg = (pkgs.callPackage ../../packages/config-fancontrol.nix {});
in
{
  hardware.fancontrol = {
    enable = true;
    config = "";
  };

  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/fancontrol.nix
  systemd.services.fancontrol = {
    overrideStrategy = "asDropinIfExists";
    serviceConfig = {
      ExecStartPre = "${fc-cfg}/bin/fancontrol-hwmon-fix.sh";
      ExecStart = lib.mkForce "${fc-bin} /etc/fancontrol";
    };
  };

  # load modules for AMD platform
  boot.kernelModules = [
    "nct6775"
  ];
}
