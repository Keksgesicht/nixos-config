{ config, pkgs, ssd-name, ...}:

let
  pkg-scu = (pkgs.callPackage ../../packages/server-and-config-update.nix {});
in
{
  systemd = {
    services."server-and-config-update@" = {
      description = "Container and Webservice Updater (config)";
      after = [
        "mnt-${ssd-name}.mount"
      ];
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = "${pkg-scu}/bin/%i.sh";

        PrivateTmp     = "yes";
        ProtectHome    = "yes";
        ProtectClock   = "yes";
        PrivateDevices = "yes";
        ProtectProc    = "invisible";

        ReadOnlyPaths = "/";
        TemporaryFileSystem = "/etc:ro";
      };
    };
    # one snapshot a day
    timers."server-and-config-update@" = {
      description = "Container and Webservice Update Timer";
      timerConfig = {
        # Run each month in the evening
        OnCalendar = "*-*-20 20:30:00";
        RandomizedDelaySec = "1h";
        AccuracySec = "100us";
        # also run when system was offline (like anacron)
        Persistent = "true";
      };
    };
  };
}


