{ pkgs, sloth, bindHomeDir, ... }:

let
  name = "MediaPlayer";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.vlc; binName = "vlc"; appFile = [
          { args.remove = "%U"; args.extra = "%U"; }
        ]; }
        pkgs.yt-dlp
      ];
      audio = true;
    };

    dbus.policies = {
      "org.freedesktop.PowerManagement.Inhibit" = "talk";
      "org.mpris.MediaPlayer2.vlc" = "own";
    };

    bubblewrap = {
      bind.ro = [
        (sloth.concat' sloth.homeDir "/git")
        (sloth.concat' sloth.homeDir "/Module")
        (sloth.xdgDocumentsDir)
        (sloth.xdgDownloadDir)
        (sloth.xdgMusicDir)
        (sloth.xdgVideosDir)
      ];
      bind.rw = [
        (bindHomeDir name "/.config/vlc")
        (bindHomeDir name "/.local/share/vlc")
      ];
    };
  };
}
