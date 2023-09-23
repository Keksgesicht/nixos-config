{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  # https://nixos.wiki/wiki/Secure_Boot
  boot = {
    bootspec.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      # $AUTH sbctl create-keys
      pkiBundle = "/etc/secureboot";
    };
  };
}
