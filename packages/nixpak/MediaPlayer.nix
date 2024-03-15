{ pkgs, bindHomeDir, ... }:

let
  name = "MediaPlayer";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.vlc; binName = "vlc"; }
        pkgs.yt-dlp
      ];
      audio = true;
    };

    dbus.policies = {
      "org.freedesktop.PowerManagement.Inhibit" = "talk";
      "org.mpris.MediaPlayer2.vlc" = "own";
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/vlc")
        (bindHomeDir name "/.local/share/vlc")
      ];
    };
  };
}
