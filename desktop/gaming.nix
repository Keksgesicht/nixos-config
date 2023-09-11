{ config, pkgs, ...}:

{
  users.users."keks".packages = with pkgs; [
    # enable saving replaybuffer through a hotkey
    (callPackage ../packages/obs-cli.nix {})
  ];

  # Enable udev rules for Steam hardware such as the Steam Controller
  hardware.steam-hardware.enable = true;

  programs = {
    steam = {
      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = true;
    };

    # optimise system performance on demand
    gamemode = {
      enable = true;
    };
  };

  # automatically run obs-studio to record replays
  systemd.user = {
    services = {
      "obs-studio-gaming" = {
        description = "OBS Studio Autostarter (gaming)";
        path = [
          pkgs.bash
          pkgs.flatpak
          pkgs.gawk
          pkgs.procps
          pkgs.psmisc
          pkgs.util-linux
          pkgs.xorg.xrandr
        ];
        script = (builtins.readFile ../files/scripts/obs-studio-gaming.sh);
        scriptArgs = "start";
      };
    };
    timers = {
      "obs-studio-gaming" = {
        description = "OBS Studio Autorestarter (gaming)";
        timerConfig = {
          OnStartupSec = "321sec";
          OnUnitInactiveSec = "123sec";
        };
        wantedBy = [
          "timers.target"
        ];
      };
    };
  };
}
