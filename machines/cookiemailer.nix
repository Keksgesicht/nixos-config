{ ssd-mnt, ... }:

{
  # Define your hostname
  networking.hostName = "cookiemailer";

  imports = [
    ../desktop/environment.nix
    ../desktop/my-user.nix
    ../hardware
    ../hardware/filesystem-single-disk.nix
    ../hardware/hetzner.nix
    ../development/base-devel.nix
    ../nix
    ../nix/secrets-pkg.nix
    ../nix/version-23-05.nix
    ../services/containers/mailcow.nix
    ../services/system/backup-snapshot.nix
    ../system
    ../system/impermanence
    ../system/impermanence/server.nix
    ../system/openssh/backup.nix
    ../system/network/server/hetzner.nix
  ];

  swapDevices = [ {
    device = "${ssd-mnt}/swapfile";
    randomEncryption.enable = true;
    options = [ "nofail" ];
    size = 4096;
  } ];
}
