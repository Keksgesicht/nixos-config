{ config, ... }:

{
  system.autoUpgrade = {
    enable = true;
    dates = "02:22";
    randomizedDelaySec = "123min";
    operation =
      if (config.services.xserver.enable) then "boot"
      else "switch";
    allowReboot = !(config.services.xserver.enable);
    rebootWindow = {
      lower = "02:00";
      upper = "07:00";
    };
  };
}
