{ bindHomeDir, ... }:
{ pkgs-stable, ... }:

let
  name = "UngoogledChromium";
  pkgs = pkgs-stable {};
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.ungoogled-chromium; binName = "chromium"; appFile = [
          { src = "chromium-browser"; args.extra = [
            "--enable-features=UseOzonePlatform" "--ozone-platform-hint=auto"
            "--force-dark-mode" "--enable-features=WebUIDarkMode"
            "--incognito"
          ]; }
        ]; }
      ];
      chromiumCleanupScript = true;
      audio = true;
      time = true;
    };

    dbus.policies = {
      "org.mpris.MediaPlayer2.chromium.*" = "own";
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/chromium")
      ];
      network = true;
    };
  };
}
