{ pkgs, bindHomeDir, ... }:

let
  name = "UngoogledChromium";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.ungoogled-chromium; binName = "chromium";
          #extraParams = "--enable-features=UseOzonePlatform --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode";
          appFileSrc = "chromium-browser"; }
      ];
      audio = true;
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
