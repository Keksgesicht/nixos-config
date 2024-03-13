{ config, pkgs, lib
, username, secrets-dir
, ... }:

{
  # Define your hostname
  networking.hostName = "pihole";

  imports = [
    ../desktop/environment.nix
    ../desktop/my-user.nix
    ../hardware/rpi-pihole
    ../development/base-devel.nix
    ../development/neovim.nix
    ../nix
    ../nix/build-cache-client.nix
    ../nix/version-23-05.nix
    ../services/containers/unbound.nix
    ../services/containers/pihole.nix
    ../services/system/backup-snapshot.nix
    ../system
    ../system/container.nix
  ];

  users.users."${username}" = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile "${secrets-dir}/keys/ssh/id_pihole.pub")
    ];
    initialPassword = "";
  };
}
