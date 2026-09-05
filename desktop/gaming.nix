{ config, pkgs, username, home-dir, ... }:

let
  xdg-config = "${home-dir}/.config";
  inherit (config.KexOS.service."dummy".service) serviceConfig;
  mango-hud = pkgs.callPackage ../packages/MangoHud.nix {};
  options = [ "NOPASSWD" ];
  usb-bind-script = ../files/scripts/usb-bind-devices-by-name.sh;
in
{
  imports = [
    ../hardware/services/gaming.nix
  ];

  users.users."${username}".packages = with pkgs; [
    # enable saving replaybuffer through a hotkey
    (callPackage ../packages/obs-cli.nix {})
  ];

  # automatically run obs-studio to record replays
  systemd.user = {
    services = {
      "obs-studio-gaming" = {
        description = "OBS Studio Autostarter (gaming)";
        path = with pkgs; [
          config.nixpak."OBS-Studio".output.env
          bash gawk procps psmisc util-linux xrandr
        ];
        serviceConfig = serviceConfig // {
          PrivateDevices = "no";
          ProtectHome = "no";
          TemporaryFileSystem = [ "/home" "/root:ro" ];
          BindPaths = [
            "%h/.var/app/OBS-Studio"
            "%h/Videos/Gaming/Desktop"
          ];
        };
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

  systemd.user.tmpfiles.users."${username}".rules = [
    "C+ ${xdg-config}/MangoHud - - - - ${mango-hud}"
  ];

  security.sudo-rs.extraRules = [ {
    users = [ username ];
    commands = [
      { inherit options; command = "${usb-bind-script} Xbox360 bind"; }
      { inherit options; command = "${usb-bind-script} Xbox360 unbind"; }
    ];
  } ];

  environment.shellAliases = {
    "usb-bind-devices-by-name.sh" = "sudo ${usb-bind-script}";
  };
}
