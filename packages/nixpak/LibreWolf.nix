{ pkgs, bindHomeDir, ... }:

let
  name = "LibreWolf";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.librewolf; binName = "librewolf"; }
      ];
      audio = true;
    };

    dbus.policies = {
      "io.gitlab.librewolf.*" = "own";
      "org.mpris.MediaPlayer2.firefox.*" = "own";
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.librewolf")
      ];
      network = true;
    };
  };
}
