{ lib, modulesPath, ssd-mnt, hdd-mnt, ... }:

let
  hd = "/dev/sda";
  rp = "/dev/disk/by-label/hetzner-btrfs-root";
  mf = lib.mkForce;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "virtio_pci" "virtio_scsi"
  ];

  boot.loader.grub.devices = [ hd ];
  fileSystems = {
    "/boot".device      = "${hd}15";
    "/nix".device       = mf rp;
    "${hdd-mnt}".device = mf rp;
    "${ssd-mnt}".device = mf rp;
  };
}
