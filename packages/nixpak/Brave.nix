{ pkgs, bindHomeDir, ... }:

let
  name = "Brave";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.brave; binName = "brave";
          #extraParams = "--enable-features=UseOzonePlatform --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode";
          appFileSrc = "brave-browser"; }
      ];
      audio = true;
    };

    dbus.policies = {
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
