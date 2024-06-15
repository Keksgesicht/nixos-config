{ pkgs, ... }:

{
  # prevent suspend when closing lid
  services.logind = {
    lidSwitch = "lock";
    lidSwitchDocked = "lock";
    lidSwitchExternalPower = "lock";
  };

  systemd.services = {
    "bluetooth-disable" = {
      enable = true;
      wantedBy = [
        "basic.target"
      ];
      after  = [
        "bluetooth.target"
        "systemd-rfkill.service"
      ];
      script = "${pkgs.util-linux}/bin/rfkill block bluetooth";
    };
  };
}
