{ lib, secrets-pkg, hdd-mnt, hdd-name, ... }:

let
  keyPathClient = secrets-pkg + "/ssh/client";
in
{
  # Define your hostname
  networking.hostName = "cookiepi";

  imports = [
    ../desktop/environment.nix
    ../desktop/my-user.nix
    ../hardware
    ../hardware/filesystem-single-disk.nix
    ../hardware/laptop/server.nix
    ../development/base-devel.nix
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
    ../services/containers/tandoor.nix
    ../services/containers/unbound.nix
    ../services/system/backup-snapshot.nix
    ../services/system/wireguard/server.nix
    ../system
    ../system/impermanence
    ../system/impermanence/server.nix
    ../system/network/server/lan.nix
  ];

  # required boot mounts
  fileSystems."/boot".device = "/dev/disk/by-uuid/4EFC-A800";
  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/867c7b32-c672-4660-aa54-57262ff3ebdf";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  swapDevices = [ {
    device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_120GB_S21UNXAGA07082H-part2";
    randomEncryption.enable = true;
  } ];

  # delayed array mount
  environment.etc."crypttab".text = ''
    ${hdd-name} /dev/disk/by-uuid/92756ea5-50ee-456c-b760-5c997fcb54ad - nofail,tpm2-device=auto
  '';
  fileSystems."${hdd-mnt}" = {
    device = lib.mkForce "/dev/disk/by-label/${hdd-name}";
    options = [ # extend filesystem-single-disk.nix
      "nofail"
      "x-systemd.requires=systemd-cryptsetup@${hdd-name}.service"
    ];
  };

  # allow remote backups
  users.users."root".openssh.authorizedKeys.keyFiles = [
    (keyPathClient + "/id_backup.pub")
  ];
}
