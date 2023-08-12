{ config, pkgs, lib, ...}:

{
  hardware.fancontrol = {
    enable = true;
    config = "${pkgs.callPackage ../../packages/fancontrol-config.nix {}}/cfg/fancontrol.config.sample";
  };

  # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/services/hardware/fancontrol.nix
  systemd.services.fancontrol = {
    overrideStrategy = "asDropinIfExists";
    serviceConfig = {
      ExecStartPre = "${pkgs.callPackage ../../packages/fancontrol-config.nix {}}/bin/fancontrol-hwmon-fix.sh";
      ExecStart = lib.mkForce "${pkgs.lm_sensors}/sbin/fancontrol /etc/fancontrol";
    };
  };
}
