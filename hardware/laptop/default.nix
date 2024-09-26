{ ... }:

{
  imports = [
    ../../system/impermanence
    ../filesystem-single-disk.nix
    ./tuxedo.nix
  ];

  # filesystem extras
  fileSystems."/boot".device = "/dev/disk/by-uuid/90CE-7A63";
  boot.initrd.luks.devices = {
    "root" = {
      device = "/dev/disk/by-uuid/c720b152-baf0-4336-bb04-83f01857cfab";
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };
  swapDevices = [ {
    device = "/dev/disk/by-id/nvme-KINGSTON_SNVS500G_50026B76856C0884-part2";
    randomEncryption.enable = true;
  } ];
}
