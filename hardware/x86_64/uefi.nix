{ lib, ... }:

{
  imports = [
    ../services/plymouth.nix
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
      systemd.enable = true;
    };

    # Bootloader
    loader = {
      timeout = lib.mkDefault 2;
      systemd-boot = {
        enable = true;
        # It is recommended to set this to false,
        # as it allows gaining root access by passing init=/bin/sh as a kernel parameter.
        editor = false;
        /*
         * "0": Standard UEFI 80x25 mode
         * "1": 80x50 mode, not supported by all devices
         * "2": The first non-standard mode provided by the device firmware, if any
         * "auto": Pick a suitable mode automatically using heuristics
         * "max": Pick the highest-numbered available mode
         * "keep": Keep the mode selected by firmware (the default)
         */
        consoleMode = "max";
        # Maximum number of latest generations in the boot menu.
        # Useful to prevent boot partition running out of disk space.
        configurationLimit = 25;
        # Make MemTest86 available from the systemd-boot menu.
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  hardware.cpu = {
    amd.updateMicrocode = true;
    intel.updateMicrocode = true;
  };
}
