{ config, pkgs, ...}:

{
  # monitor disk status
  services.smartd = {
    enable = true;
    # otherwise use .devices list
    autodetect = true;
    notifications = {
      # further options are .x11 or .mail, but KDE already reacts to on wall messages
      wall.enable = true;
      # send a test notification on startup
      test = true;
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
