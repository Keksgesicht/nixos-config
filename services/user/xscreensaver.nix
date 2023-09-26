{ config, pkgs, ... }:

{
  systemd.user.services = {
    "xscreensaver" = {
      description = "Screensaver for X11";
      environment = {
        GDK_BACKEND = "x11";
      };
      serviceConfig = {
        ExecStart = "${pkgs.xscreensaver}/bin/xscreensaver --no-splash";
        PrivateTmp  = "yes";
        ProtectHome = "yes";
        ProtectProc = "invisible";
        ReadOnlyPaths = "/";
      };
    };
  };
}
