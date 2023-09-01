{ config, pkgs, ... }:

{
  services.apcupsd = {
    enable = true;
    configText = ''
      UPSCABLE usb
      UPSTYPE usb

      BATTERYLEVEL 42
      MINUTES 5

      NISIP 127.0.0.1
      NISPORT 3551
    '';
  };
}
