# https://nixos.wiki/wiki/KDE
{ config, pkgs, ...}:

{
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the KDE Plasma Desktop Environment (wayland by default).
    displayManager = {
      sddm = {
        enable = true;
        autoNumlock = true;
        # the line starts with "Current="
        # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/services/x11/display-managers/sddm.nix#L39
        theme = ''
          breeze
          CursorTheme=LyraG-cursors
          Font=Noto Sans,10,-1,50,0,0,0,0,0
        '';
      };
      defaultSession = "plasmawayland";
    };
    desktopManager.plasma5.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  # enable KDEconnect
  programs.kdeconnect.enable = true;

  # I do not need this from nix packages
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    kmailtransport
    okular
    oxygen
    plasma-browser-integration
  ];

  users.users."keks" = {
    packages = with pkgs.libsForQt5; with pkgs; [
      kate
      # use digital clock with PIM plugin
      akonadi-calendar
      kdepim-addons
      merkuro
      # security stuff
      ksshaskpass
      # graphics info
      clinfo
      glxinfo
      vulkan-tools
      wayland-utils
    ];
  };

  systemd.services = {
    /*
     * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogFilterPatterns=
     * https://forum.manjaro.org/t/stable-update-2023-06-04-kernels-gnome-44-1-plasma-5-27-5-python-3-11-toolchain-firefox/141610/3
     * do not log messages with the following regex
     */
    "user@" = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        TimeoutStopSec = 23;
        LogFilterPatterns = [
          #"~QML"
          #"~QObject:"
          #"~QFont::"
          "~kwin_screencast: Dropping"
        ];
      };
    };

    # faster shutdowns
    "display-manager" = {
      serviceConfig = {
        TimeoutStopSec = 23;
      };
    };
  };

  systemd.tmpfiles.rules =
  let
    qtver = pkgs.libsForQt5.qtbase.version;
    plasma-addons = pkgs.libsForQt5.kdeplasma-addons;
    workspace-addons = pkgs.libsForQt5.plasma-workspace;
    kdepim-addons = pkgs.libsForQt5.kdepim-addons;
  in [
    # calendar does not show events without it
    # https://github.com/NixOS/nixpkgs/issues/143272
    # https://bugs.kde.org/show_bug.cgi?id=400451
    # https://invent.kde.org/plasma/plasma-workspace/-/blob/4df78f841cc16a61d862b5b183e773e9f66436b8/ktimezoned/ktimezoned.cpp#L124
    "L+ /usr/share/zoneinfo - - - - ${pkgs.tzdata}/share/zoneinfo"

    # fix showing duplicate events in calendar widget of plasma panel
    "L+ /usr/lib/qt/plugins/plasmacalendarplugins/astronomicalevents    - - - - ${plasma-addons}/lib/qt-${qtver}/plugins/plasmacalendarplugins/astronomicalevents"
    "L+ /usr/lib/qt/plugins/plasmacalendarplugins/astronomicalevents.so - - - - ${plasma-addons}/lib/qt-${qtver}/plugins/plasmacalendarplugins/astronomicalevents.so"
    "L+ /usr/lib/qt/plugins/plasmacalendarplugins/holidays              - - - - ${workspace-addons}/lib/qt-${qtver}/plugins/plasmacalendarplugins/holidays"
    "L+ /usr/lib/qt/plugins/plasmacalendarplugins/holidays.so           - - - - ${workspace-addons}/lib/qt-${qtver}/plugins/plasmacalendarplugins/holidaysevents.so"
    "L+ /usr/lib/qt/plugins/plasmacalendarplugins/pimevents             - - - - ${kdepim-addons}/lib/qt-${qtver}/plugins/plasmacalendarplugins/pimevents"
    "L+ /usr/lib/qt/plugins/plasmacalendarplugins/pimevents.so          - - - - ${kdepim-addons}/lib/qt-${qtver}/plugins/plasmacalendarplugins/pimevents.so"
  ];
}
