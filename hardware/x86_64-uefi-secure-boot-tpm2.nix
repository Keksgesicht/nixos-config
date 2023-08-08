{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "sd_mod"
        "sdhci_pci"
        "usb_storage"
        "xhci_pci"
        # if it does not work, look at what the following gives you:
        # > lsmod | grep tpm
        # > systemd-cryptenroll --tpm2-device=list
        "tpm_crb"
        "tpm_tis"
      ];
      kernelModules = [ ];
      systemd.enable = true;
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];

    # Bootloader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu = {
    amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
