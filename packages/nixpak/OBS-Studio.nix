{ pkgs, sloth, bindHomeDir, ... }:

let
  name = "OBS-Studio";

  obs-cli = (pkgs.callPackage ../obs-cli.nix {});
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.obs-studio; binName = "obs"; appFile = [
          { src = "com.obsproject.Studio"; args.extra = [
            "--profile" "\"Default\""
            "--collection" "\"Default\""
          ]; }
        ]; }
        # tools needed by obs-studio
        pkgs.ffmpeg
        # global hotkeys workaround
        obs-cli
      ];
      variables = {
        KDE_NO_GLOBAL_MENU = "1";
      };
      audio = true;
    };

    dbus.policies = {
      "org.kde.StatusNotifierWatcher" = "talk"; # tray icon on KDE Plasma
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/obs-studio")
        (sloth.mkdir (sloth.concat' sloth.xdgVideosDir "/Gaming/Desktop"))
        (sloth.mkdir (sloth.concat' sloth.xdgVideosDir "/Work"))
      ];
      network = true;
    };
  };
}
