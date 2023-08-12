{ config, pkgs, ...}:

{
  # Enable udev rules for Steam hardware such as the Steam Controller
  hardware.steam-hardware.enable = true;

  # Open ports in the firewall for Steam Remote Play
  programs.steam.remotePlay.openFirewall = true;

  # automatically run obs-studio to record replays
  systemd.user = {
    services = {
      "obs-studio-gaming" = {
        description = "OBS Studio Autostarter (gaming)";
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
