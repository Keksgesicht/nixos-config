{ pkgs, bindHomeDir, ... }:

let
  name = "Ferdium";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.ferdium; binName = "ferdium"; appFile = [
          { args.extra = [
            "--ozone-platform-hint=auto"
            "--enable-features=UseOzonePlatform"
          ]; }
        ]; }
      ];
      variables = {
        LD_LIBRARY_PATH = [
          "${pkgs.pulseaudio}/lib"
        ];
      };
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
        (bindHomeDir name "/.config/Ferdium")
      ];
      network = true;
    };
  };
}
