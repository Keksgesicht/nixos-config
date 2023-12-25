# ~/.local/share/applications/*.desktop
# https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.desktopEntries
# https://github.com/nix-community/home-manager/blob/master/modules/misc/xdg-desktop-entries.nix
{ pkgs, ... }:

let
  my-audio = pkgs.callPackage ../../packages/my-audio.nix {};
  obsrebuf = pkgs.callPackage ../../packages/obs-hotkeys.nix {};
  xs-saver = pkgs.writeShellScriptBin "toggle-xscreensaver.sh" (''
    export PATH=${pkgs.systemd}/bin
  '' + (builtins.readFile ../../files/scripts/toggle-xscreensaver.sh));
in
{
  xdg.desktopEntries = {
    "relink-virtual-devices.sh" = {
      exec = "${my-audio}/bin/audio-relink-virtual-devices.sh";
      name = "relink-virtual-devices.sh";
      type = "Application";
      noDisplay = true;
    };
    "restart-audio.sh" = {
      exec = "${my-audio}/bin/restart-audio.sh";
      name = "restart-audio.sh";
      type = "Application";
      noDisplay = true;
    };
    "toggle-mute-chat.sh" = {
      exec = "${my-audio}/bin/toggle-mute-chat.sh";
      name = "toggle_mute_chat.sh";
      type = "Application";
      noDisplay = true;
    };
    "toggle-mute-gaming.sh" = {
      exec = "${my-audio}/bin/toggle-mute-gaming.sh";
      name = "toggle_mute_gaming.sh";
      type = "Application";
      noDisplay = true;
    };
    "toggle-mute-mic.sh" = {
      exec = "${my-audio}/bin/toggle-mute-mic.sh";
      name = "toggle_mute_mic.sh";
      type = "Application";
      noDisplay = true;
    };
    "rfkill-bluetooth" = {
      exec = "rfkill toggle bluetooth";
      name = "rfkill toggle bluetooth";
      type = "Application";
      noDisplay = true;
      startupNotify = false;
      settings = {
        X-KDE-GlobalAccel-CommandShortcut = "true";
      };
    };

    "toggle-xscreensaver" = {
      exec = "${xs-saver}/bin/toggle-xscreensaver.sh";
      name = "xscreensaver.sh";
      type = "Application";
      noDisplay = true;
    };
    "save-replay-buffer" = {
      exec = "${obsrebuf}/bin/saveReplayBuffer.sh";
      name = "saveReplayBuffer.sh";
      type = "Application";
      noDisplay = true;
    };
  };
}
