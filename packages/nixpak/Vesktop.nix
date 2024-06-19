{ bindHomeDir, ... }:
{ pkgs, ... }:

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
            "--enable-features=WebRTCPipeWireCapturer"
          ]; }
        ]; }
      ];
      chromiumCleanupScript = true;
      audio = true;
      time  = true;
    };

    dbus.policies = {
      "org.freedesktop.Notifications" = "talk";
      "org.freedesktop.PowerManagement.Inhibit" = "talk";
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
