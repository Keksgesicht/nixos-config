# ~/.local/share/applications/*.desktop
# https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.desktopEntries
# https://github.com/nix-community/home-manager/blob/master/modules/misc/xdg-desktop-entries.nix
username:
{ config, pkgs, lib, ... }:

let
  profile-dir = "/etc/profiles/per-user/${username}/share/applications";
  mkOOSS = config.lib.file.mkOutOfStoreSymlink;

  my-audio = pkgs.callPackage ../../packages/my-audio.nix {};
  obsrebuf = pkgs.callPackage ../../packages/obs-hotkeys.nix {};
  xs-saver = pkgs.writeShellScriptBin "toggle-xscreensaver.sh" (''
    export PATH=${pkgs.systemd}/bin
  '' + (builtins.readFile ../../files/scripts/toggle-xscreensaver.sh));
  nm-wifi  = ../../files/scripts/toggle-nm-wifi.sh;
in
{
  xdg.desktopEntries = {
    # entries for special and personal applications

    "relink-virtual-devices.sh" = {
      exec = "${my-audio}/bin/audio-relink-virtual-devices.sh";
      name = "Reconnect wires between virtual audio sinks/sources";
      type = "Application";
      noDisplay = true;
    };
    "restart-audio.sh" = {
      exec = "${my-audio}/bin/audio-restart.sh";
      name = "Restart all Audio Services";
      type = "Application";
      noDisplay = true;
    };
    "toggle-mute-chat.sh" = {
      exec = "${my-audio}/bin/audio-toggle-mute-chat.sh";
      name = "Toggle mute of virtual sink for Chat Apps";
      type = "Application";
      noDisplay = true;
    };
    "toggle-mute-gaming.sh" = {
      exec = "${my-audio}/bin/audio-toggle-mute-gaming.sh";
      name = "Toggle mute special virtual sink for Gaming Apps";
      type = "Application";
      noDisplay = true;
    };
    "toggle-mute-mic.sh" = {
      exec = "${my-audio}/bin/audio-toggle-mute-mic.sh";
      name = "Toggle mute of main Microphone";
      type = "Application";
      noDisplay = true;
    };
    "rfkill-bluetooth" = {
      exec = "rfkill toggle bluetooth";
      name = "Enable/Disable Bluetooth Device";
      type = "Application";
      noDisplay = true;
      startupNotify = false;
    };
    "rfkill-wlan" = {
      exec = "${nm-wifi}";
      name = "Enable/Disable Bluetooth Device";
      type = "Application";
      noDisplay = true;
      startupNotify = false;
    };

    "toggle-xscreensaver.sh" = {
      exec = "${xs-saver}/bin/toggle-xscreensaver.sh";
      name = "Run/Stop XScreensaver";
      type = "Application";
      noDisplay = true;
    };
    "save-replay-buffer.sh" = {
      exec = "${obsrebuf}/bin/saveReplayBuffer.sh";
      name = "Save OBS-Studio ReplayBuffer";
      type = "Application";
      noDisplay = true;
    };

    # desktop entries for common applications

    "Vivado" = {
      exec = "${pkgs.bash}/bin/bash -c \"source /opt/cad/Xilinx/Vivado/2019.1/settings64.sh && exec vivado\"";
      name = "Vivado";
      icon = "/opt/cad/Xilinx/Vivado/2019.1/doc/images/vivado_logo.png";
      terminal = false;
      noDisplay = false;
      startupNotify = true;
    };
    "Vivado_HLS" = {
      exec = "${pkgs.bash}/bin/bash -c \"source /opt/cad/Xilinx/Vivado/2019.1/settings64.sh && exec vivado_hls\"";
      name= "Vivado_HLS";
      icon = "/opt/cad/Xilinx/Vivado/2019.1/doc/images/vivado_logo.png";
      terminal = false;
      noDisplay = false;
      startupNotify = true;
    };

    # override nixpkgs desktop entries

    "pavucontrol" = {
      exec = "${pkgs.pavucontrol}/bin/pavucontrol -r";
      name = "PulseAudio Volume Control";
      type = "Application";
      icon = "multimedia-volume-control";
      comment = "Adjust the volume level";
      startupNotify = true;
      categories = [
        "AudioVideo" "Audio"
        "Mixer"
        "GTK" "Settings" "X-XFCE-SettingsDialog" "X-XFCE-HardwareSettings"
      ];
      settings = {
        Keywords = (lib.concatStringsSep ";" [
          "pavucontrol" "Volume"
          "Microphone" "Headset" "Speakers" "Headphones"
          "Output" "Input" "Devices" "Playback" "Recording" "System Sounds" "Sound Card"
          "Fade" "Balance" "Audio" "Mixer"
          "Settings" "Preferences"
        ]);
      };
    };

    # override flatpak desktop entries

    "com.heroicgameslauncher.hgl" = {
      exec = (lib.concatStringsSep " " [
        "${pkgs.flatpak}/bin/flatpak" "run"
        "com.heroicgameslauncher.hgl"
        "--enable-features=UseOzonePlatform" "--ozone-platform=wayland"
      ]);
      name = "Heroic Games Launcher";
      type = "Application";
      icon = "com.heroicgameslauncher.hgl";
      comment = "An Open Source GOG and Epic Games launcher";
      terminal = false;
      mimeType = [
        "x-scheme-handler/heroic"
      ];
      categories = [
        "Game"
      ];
      settings = {
        StartupWMClass = "Heroic";
        X-Flatpak = "com.heroicgameslauncher.hgl";
      };
    };

    "com.obsproject.Studio" = {
      exec = (lib.concatStringsSep " " [
        "${pkgs.flatpak}/bin/flatpak" "run"
        "com.obsproject.Studio"
        "--profile" "\"Default\"" "--collection" "\"Default\""
      ]);
      name = "OBS Studio";
      type = "Application";
      icon = "com.obsproject.Studio";
      comment = "Free and Open Source Streaming/Recording Software";
      genericName = "Streaming/Recording Software";
      terminal = false;
      startupNotify = true;
      categories = [
        "AudioVideo" "Recorder"
      ];
      settings = {
        StartupWMClass = "obs";
        X-Flatpak = "com.obsproject.Studio";
      };
    };
  };

  # aarggg.. flatpak is ealier in XDG_DATA_DIRS
  xdg.dataFile = {
    "applications/com.heroicgameslauncher.hgl.desktop".source   = mkOOSS "${profile-dir}/com.heroicgameslauncher.hgl.desktop";
    "applications/com.obsproject.Studio.desktop".source         = mkOOSS "${profile-dir}/com.obsproject.Studio.desktop";
  };
}
