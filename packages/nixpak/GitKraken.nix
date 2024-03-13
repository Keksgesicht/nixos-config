{ pkgs, sloth, bindHomeDir, ... }:

let
  name = "GitKraken";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.gitkraken; binName = "gitkraken";
          #extraParams = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
          appFileSrc = "GitKraken"; }
      ];
    };

    bubblewrap = {
      bind.ro = [
        (sloth.concat' sloth.xdgConfigHome "/git")
      ];
      bind.rw = [
        (bindHomeDir name "/.gitkraken")
        (bindHomeDir name "/.config/GitKraken")
        (sloth.concat' sloth.homeDir "/git")
      ];
      sockets.x11 = true; # WTF during startup needed
    };
  };
}
