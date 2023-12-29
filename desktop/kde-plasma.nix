# https://nixos.wiki/wiki/KDE
{ config, pkgs, lib, inputs, ...}:

let
  qt-lib = "/usr/lib/qt";
in
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
      kruler
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

  systemd.user.services = {
    # calendar of digital clock widget is not configureable without it
    # fix showing duplicate events in calendar widget of plasma panel
    "plasma-plasmashell" = {
      overrideStrategy = "asDropin";
      environment = {
        # prevent defaults
        PATH = lib.mkForce null;
        TZDIR = lib.mkForce null;
        LOCALE_ARCHIVE = lib.mkForce null;
        # will get extended by NixOS Qt Wrapper in binary itself
        QT_PLUGIN_PATH = "${qt-lib}/plugins";
        QML2_IMPORT_PATH = "${qt-lib}/qml";
      };
    };
  };

  systemd.tmpfiles.rules =
  let
    qtver = pkgs.libsForQt5.qtbase.version;

    cal-plug-path = "plugins/plasmacalendarplugins";
    qt-cal-plug   = "${qt-lib}/${cal-plug-path}";

    kdepim-addons = pkgs.libsForQt5.kdepim-addons;
    plasma-addons = pkgs.libsForQt5.kdeplasma-addons;
    workspace-addons = pkgs.libsForQt5.plasma-workspace;

    mkCalPlugSym = p: l: (lib.lists.forEach l (e:
      "L+ ${qt-cal-plug}/${e} - - - - ${p}/lib/qt-${qtver}/${cal-plug-path}/${e}"
    ));
  in
  [
    # calendar does not show events without it
    # https://github.com/NixOS/nixpkgs/issues/143272
    # https://bugs.kde.org/show_bug.cgi?id=400451
    # https://invent.kde.org/plasma/plasma-workspace/-/blob/4df78f841cc16a61d862b5b183e773e9f66436b8/ktimezoned/ktimezoned.cpp#L124
    "L+ /usr/share/zoneinfo - - - - ${pkgs.tzdata}/share/zoneinfo"

    # calendar of digital clock widget is not configureable without it
    # fix showing duplicate events in calendar widget of plasma panel
    "L+ ${qt-lib}/qml                        - - - - /run/current-system/sw/lib/qt-${qtver}/qml"
  ]
  ++ mkCalPlugSym plasma-addons    [ "astronomicalevents" "astronomicalevents.so" ]
  ++ mkCalPlugSym workspace-addons [ "holidays" "holidaysevents.so" ]
  ++ mkCalPlugSym kdepim-addons    [ "pimevents" "pimevents.so" ]
  ;

  home-manager.users."keks" =
  let
    plasma-manager = inputs.plasma-manager;
  in
  {
    imports = [
      plasma-manager.homeManagerModules.plasma-manager
      # nix run github:pjones/plasma-manager
      home-manager/plasma-manager.nix
      home-manager/plasma-manager-extra.nix
    ];

    programs.plasma.configFile =
    if (config.networking.hostName == "cookiethinker") then
    {
      "kcminputrc"."Keyboard"."NumLock"    = lib.mkForce 0;
      "kscreenlockerrc"."Daemon"."Timeout" = lib.mkForce 3;
      "kwinrulesrc"."General"."count"      = lib.mkForce 3;
      "kwinrulesrc"."General"."rules"      = lib.mkForce "6,8,9";
    } else {};
  };
}
