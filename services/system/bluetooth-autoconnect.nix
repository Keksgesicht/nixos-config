{ config, pkgs, ...}:

{
  systemd = {
    services = {
      "bluetooth-autoconnect" = {
        description = "Bluetooth autoconnect service";
        path = with pkgs; [
          (python3.withPackages (ps: with ps; [
            dbus-python
            gbulb
          ]))
        ];
        before = [
          "bluetooth.service"
        ];
        serviceConfig = {
          Type      = "simple";
          ExecStart = "${pkgs.callPackage ../../packages/bluetooth-autoconnect.nix {}}/bin/bluetooth-autoconnect --daemon";
          PrivateTmp   = "yes";
          ProtectHome  = "yes";
          ProtectClock = "yes";
          ProtectProc  = "invisible";
        };
        wantedBy = [
          "bluetooth.service"
        ];
      };
    };
  };
}
