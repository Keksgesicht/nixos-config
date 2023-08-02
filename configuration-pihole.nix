# sd-image-rpi3.nix

{ config, pkgs, lib, ... }:
{
  system.stateVersion = "23.05";

  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];
  sdImage.compressImage = false;
#  installer.cloneConfig = true;

  environment.etc = {
    nixos-configuration-nix = {
      uid = 0;
      gid = 0;
      mode = "0644";
      target = "nixos/configuration.nix";
      source = ./sd-image-rpi3.nix;
    };
  };

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # systemPackages
  environment.systemPackages = with pkgs; [
    curl wget nano bind iptables
  ];

  services.openssh = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  #virtualisation.docker.enable = true;
  networking.firewall.enable = false;

  # Networking
  networking = {
    hostName = "rpi-nixos";
    useDHCP = true;
  };

  # make system useable during (re)build
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
  nix.daemonIOSchedPriority = 7;

  # put your own configuration here, for example ssh keys:
  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = false;
  users.groups = {
    nixos = {
      gid = 1000;
      name = "nixos";
    };
  };
  users.users = {
    nixos = {
      isNormalUser = true;
      initialPassword = "qwerty123";
      uid = 1000;
      home = "/home/nixos";
      name = "nixos";
      group = "nixos";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGVcKfTJylXQAdKWTmozXItrquCuODasumuWZ+7Mz9o nix@nixos-installer"
      ];
    };
  };
}
