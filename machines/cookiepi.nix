{ pkgs, ... }:

let
  secrets-pkg = (pkgs.callPackage ../packages/my-secrets.nix {});
  keyPathClient = secrets-pkg + "/ssh/client";
in
{
  # Define your hostname
  networking.hostName = "cookiepi";

  imports = [
    ../desktop/environment.nix
    ../desktop/home-manager
    ../desktop/my-user.nix
    ../hardware
    ../hardware/filesystem-single-disk.nix
    ../hardware/services/impermanence.nix
    ../development/base-devel.nix
    ../development/neovim.nix
    ../nix
    ../nix/build-cache-client.nix
    ../nix/build-cache-server.nix
    ../nix/secrets-pkg.nix
    ../nix/version-23-05.nix
    ../services/system/files-cleanup.nix
    ../services/containers/dyndns.nix
    ../services/containers/nextcloud.nix
    ../services/containers/pihole.nix
    ../services/containers/proxy.nix
    ../services/containers/unbound.nix
    ../services/system/backup-snapshot.nix
    ../system
    ../system/network/server/lan.nix
  ];

  # filesystem extras
  fileSystems."/boot".device = "/dev/disk/by-uuid/4EFC-A800";
  boot.initrd.luks.devices = {
    "root" = {
      device = "/dev/disk/by-uuid/92756ea5-50ee-456c-b760-5c997fcb54ad";
    };
  };
  swapDevices = [ {
    device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_1TB_S2RFNX0HA26869P-part2";
    randomEncryption.enable = true;
  } ];

  # allow remote backups
  users.users."root".openssh.authorizedKeys.keyFiles = [
    (keyPathClient + "/id_backup.pub")
  ];
}
