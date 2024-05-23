{ pkgs, bindHomeDir, ... }:

let
  name = "Brave";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.brave; binName = "brave"; appFile = [
          { src = "brave-browser"; args.extra = [
            "--enable-features=UseOzonePlatform" "--ozone-platform-hint=auto"
            "--force-dark-mode" "--enable-features=WebUIDarkMode"
          ]; }
        ]; }
      ];
      chromiumCleanupScript = true;
      audio = true;
      time = true;
    };

    dbus.policies = {
      "org.freedesktop.PowerManagement.Inhibit" = "talk";
      "org.mpris.MediaPlayer2.brave.*" = "own";
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/BraveSoftware")
      ];
      network = true;
    };
  };
}
