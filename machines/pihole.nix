{ config, pkgs, lib, ... }:

{
  # Define your hostname
  networking.hostName = "pihole";

  imports = [
    ../desktop/environment.nix
    ../desktop/user-keks.nix
    ../hardware/rpi-pihole
    ../development/base-devel.nix
    ../development/neovim.nix
    ../nix
    ../nix/version-23-05.nix
    ../services/containers/unbound.nix
    ../services/containers/pihole.nix
    ../services/system/backup-snapshot.nix
    ../system
    ../system/container.nix
  ];

  users.users."keks" = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile "/etc/nixos/secrets/keys/ssh/id_rsa_pihole.pub")
    ];
    initialPassword = "";
  };
}
