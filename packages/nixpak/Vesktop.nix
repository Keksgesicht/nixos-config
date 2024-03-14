{ pkgs, bindHomeDir, ... }:

let
  name = "Vesktop";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.vesktop; binName = "vesktop"; appFile = [
          { args.extra = [
            "--ozone-platform-hint=auto" "--enable-features=UseOzonePlatform"
            "--disable-gpu" # either this or x11
            "--enable-features=WebRTCPipeWireCapturer"
          ]; }
        ]; }
      ];
      audio = true;
      time  = true;
    };

    dbus.policies = {
      "org.freedesktop.Notifications" = "talk";
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/VencordDesktop")
        (bindHomeDir name "/.config/vesktop")
      ];
      network = true;
    };
  };
}
