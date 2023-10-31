{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  # monitor disk status
  services.smartd = {
    enable = true;
    # otherwise use .devices list
    autodetect = true;
    notifications = {
      wall.enable = true;
      x11.enable = true;
    };
  };

  /*
   * Reliability, Availability and Serviceability) logging tool
   * It records memory errors, using the EDAC tracing events.
   * https://github.com/mchehab/rasdaemon
   */
  hardware.rasdaemon = {
    enable = true;
    record = true;
    config = ''
      # defaults from included config
      PAGE_CE_REFRESH_CYCLE="24h"
      PAGE_CE_THRESHOLD="50"
      PAGE_CE_ACTION="soft"
    '';
     #mainboard = "";
     #labels = "";
  };

  # firmware update
  services.fwupd = {
    enable = true;
    #extraRemotes = [];
    #EspLocation = /boot;
  };
}
