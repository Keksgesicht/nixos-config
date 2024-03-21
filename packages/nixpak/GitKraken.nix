{ pkgs, sloth, bindHomeDir, ... }:

let
  name = "GitKraken";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.gitkraken; binName = "gitkraken"; appFile = [
          { src = "GitKraken"; args.extra = [
            "--enable-features=UseOzonePlatform" "--ozone-platform=wayland"
          ]; }
        ]; }
      ];
      time = true;
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

  nixpkgs.allowUnfreePackages = [ pkgs.gitkraken ];
}
