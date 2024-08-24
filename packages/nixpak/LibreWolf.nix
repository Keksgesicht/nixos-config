{ sloth, bindHomeDir, ... }:
{ pkgs-stable, ... }:

let
  pkgs = pkgs-stable {};
  name = "LibreWolf";

  arkenfox-lw = (pkgs.callPackage ../arkenfox-user.js.nix {
    patchSet = "LibreWolf";
  });
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
      bind.ro = [
        [
          (arkenfox-lw)
          (sloth.concat' sloth.homeDir "/.librewolf/user.js")
        ]
        (sloth.mkdir (sloth.concat' sloth.homeDir "/Downloads/read-only"))
      ];
      bind.rw = [
        (bindHomeDir name "/.librewolf")
        (sloth.mkdir (sloth.concat' sloth.homeDir "/Downloads/read-write"))
      ];
      network = true;
    };
  };
}
