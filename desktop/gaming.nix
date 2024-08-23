{ config, pkgs, username, home-dir, ... }:

let
  xdg-config = "${home-dir}/.config";

  mango-hud = pkgs.callPackage ../packages/MangoHud.nix {};
  usb-bind-pkg = pkgs.callPackage ../packages/usb-bind.nix {};
in
{
  imports = [
    ../hardware/services/gaming.nix
  ];

  users.users."${username}".packages = with pkgs; [
    # enable saving replaybuffer through a hotkey
    (callPackage ../packages/obs-cli.nix {})
    # enable/disable USB devices
    usb-bind-pkg
  ];

  # automatically run obs-studio to record replays
  systemd.user = {
    services = {
      "obs-studio-gaming" = {
        description = "OBS Studio Autostarter (gaming)";
        path = [
          config.nixpak."OBS-Studio".output.env
          pkgs.bash
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

  systemd.tmpfiles.rules = [
    "C+ ${xdg-config}/MangoHud - - - - ${mango-hud}"
  ];

  security.sudo.extraRules = [ {
    users = [ username ];
    commands = [
      {
        command = "${usb-bind-pkg}/bin/usb-bind-devices-by-name.sh Xbox360 bind";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${usb-bind-pkg}/bin/usb-bind-devices-by-name.sh Xbox360 unbind";
        options = [ "NOPASSWD" ];
      }
    ];
  } ];

  environment.shellAliases = {
    "usb-bind-devices-by-name.sh" = "sudo ${usb-bind-pkg}/bin/usb-bind-devices-by-name.sh";
  };
}
