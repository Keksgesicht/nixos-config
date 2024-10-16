{ sloth, appDir, bindHomeDir, ... }:
{ pkgs, ... }:

let
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
      "org.mozilla.firefox.*" = "own";
      "org.mpris.MediaPlayer2.firefox.*" = "own";
    };

    bubblewrap = {
      bind.ro = [
        [
          # mozilla.cfg
          ("${pkgs.librewolf}/lib/librewolf")
          ("/app/etc/firefox")
        ]
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
