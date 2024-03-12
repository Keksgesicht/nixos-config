{ pkgs, bindHomeDir, ... }:

let
  name = "Ferdium";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.ferdium; binName = "ferdium";
          extraParams = "--ozone-platform-hint=auto --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WaylandWindowDecorations"; }
      ];
      audio = true;
      time  = true;
    };

    dbus.policies = {
      "org.freedesktop.Notifications" = "talk";
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/Ferdium")
      ];
      network = true;
    };
  };
}
