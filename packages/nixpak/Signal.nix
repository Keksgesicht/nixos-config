{ pkgs, bindHomeDir, ... }:

let
  name = "Signal";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.signal-desktop; binName = "signal-desktop"; appFile = [
          { args.remove = "--use-tray-icon"; }
        ]; }
      ];
      variables = {
        SIGNAL_USE_TRAY_ICON = "0";
        SIGNAL_START_IN_TRAY = "0";
      };
      audio = true;
      time  = true;
    };

    dbus.policies = {
      "org.freedesktop.Notifications" = "talk";
      "org.freedesktop.PowerManagement" = "talk";
      "org.freedesktop.ScreenSaver" = "talk";
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/Signal")
      ];
      network = true;
      sockets.x11 = true; # wayland does not work :(
    };
  };
}
