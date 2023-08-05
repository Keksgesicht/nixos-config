{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos-installer";
    firewall.enable = false;
    useDHCP = true;
  };

  imports = [
    ./.
    ./upstream-23-05.nix
    ../hardware/x86_64-uefi.nix
    ../system/base-pkgs.nix
    ../system/shell-zsh.nix
  ];

  users.groups.nix = {
    gid = 1000;
    name = "nix";
  };
  users.users.nix = {
    isNormalUser = true;
    initialPassword = "qwerty123";
    uid = 1000;
    home = "/home/nix";
    name = "nix";
    group = "nix";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGVcKfTJylXQAdKWTmozXItrquCuODasumuWZ+7Mz9o nix@nixos-installer"
    ];
  };
}
