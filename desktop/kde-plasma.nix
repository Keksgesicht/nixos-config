# https://nixos.wiki/wiki/KDE
{ config, pkgs, lib, inputs, username, ...}:

let
  libKDE = pkgs.kdePackages;
  plasma = "plasma6";
  qt-ver = "6";

  lsp-wrapper = (import ../development/language-server-wrapper.nix);
  my-functions = (import ../nix/my-functions.nix lib);
in
with my-functions;
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment (wayland by default).
  services.desktopManager."${plasma}".enable = true;
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
      theme = "breeze";
    };
    defaultSession = "plasma";
  };

  # enable KDEconnect
  programs.kdeconnect.enable = true;

  # I do not need this from nix packages
  environment."${plasma}".excludePackages = with libKDE; [
    elisa
    kate
    khelpcenter
    kmailtransport
    oxygen
    plasma-browser-integration
  ];

  users.users."${username}" = {
    packages = [
      libKDE.discover
      libKDE.kruler
      (lsp-wrapper pkgs lib libKDE.kate "kate")
      # use digital clock with PIM plugin
      libKDE.akonadi-calendar
      libKDE.merkuro
      # security stuff
      libKDE.ksshaskpass
      # graphics info
      pkgs.clinfo
      pkgs.glxinfo
      pkgs.vulkan-tools
      pkgs.wayland-utils
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
          "~kwin_screencast: Dropping"
          "~ERROR: SSL connect error ::::: FUNCTION: curl::curl_easy::perform"
          "~handshake failed; returned -1, SSL error code 1, net_error -100"
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

  systemd.tmpfiles.rules = [
    # calendar does not show events without it
    # https://github.com/NixOS/nixpkgs/issues/143272
    # https://bugs.kde.org/show_bug.cgi?id=400451
    # https://invent.kde.org/plasma/plasma-workspace/-/blob/4df78f841cc16a61d862b5b183e773e9f66436b8/ktimezoned/ktimezoned.cpp#L124
    "L+ /usr/share/zoneinfo - - - - ${pkgs.tzdata}/share/zoneinfo"
  ];

  systemd.user.services = {
    # calendar of digital clock widget is not configureable without it
    # fix showing duplicate events in calendar widget of plasma panel
    "plasma-plasmashell" =
    let
      kdepim-addons = libKDE.kdepim-addons;
      kdepim-qml-path = "${kdepim-addons}/lib/qt-${qt-ver}/qml";
      kdepim-plugins-path = "${kdepim-addons}/lib/qt-${qt-ver}/plugins";
    in
    {
      overrideStrategy = "asDropin";
      environment = {
        # prevent defaults
        PATH = lib.mkForce null;
        TZDIR = lib.mkForce null;
        LOCALE_ARCHIVE = lib.mkForce null;
        # calendar of digital clock widget is not configureable without it
        # fix showing duplicate events in calendar widget of plasma panel
        QT_PLUGIN_PATH = "${kdepim-plugins-path}";
        NIXPKGS_QT6_QML_IMPORT_PATH = "${kdepim-qml-path}";
      };
    };
  };

  # apply manual fixes instead of breaking plasmashell on every nixos-rebuild
  # https://github.com/NixOS/nixpkgs/issues/292632
  # try to avoid running:
  # rm -v ~/.cache/ksycoca*
  # systemctl --user restart plasma-plasmashell.service
  system.userActivationScripts.rebuildSycoca = lib.mkForce ''
    # force plasma to rescan for .desktop files
    ${pkgs.xdg-utils}/bin/xdg-desktop-menu forceupdate
    # give hints for a clean plasma replacement operation
    echo 'If the plasma panel or the kickoff menu does not want'
    echo 'to start applications anymore. Run the following:'
    echo '${libKDE.plasma-workspace}/bin/plasmashell --replace &; disown'
  '';

  home-manager.users."${username}" =
  let
    plasma-manager = inputs.plasma-manager;
  in
  {
    imports = [
      plasma-manager.homeManagerModules.plasma-manager
      # nix run github:pjones/plasma-manager
    ];

    # luckily home-manager runs after systemd tmpfiles on boot
    programs.plasma.enable = true;
    programs.plasma.configFile =
    if (config.networking.hostName == "cookiethinker") then
    {
      "akonadi_davgroupware_resource_0rc"."General"."refreshInterval".value = "15";
      "kcminputrc"."Keyboard"."NumLock".value    = 1;
      "kscreenlockerrc"."Daemon"."Timeout".value = 3;
      "kwinrulesrc"."General"."count".value      = 3;
      "kwinrulesrc"."General"."rules".value      = "6,8,9";

      "plasma-org.kde.plasma.desktop-appletsrc" = {
        "Containments][29][Applets][47][Configuration][Appearance" = {
          "autoFontAndSize".value = false;
          "fontFamily".value = "Noto Sans";
          "fontSize".value = 7;
          "fontStyleName".value = "Regular";
        };
      };
    }
    else if (config.networking.hostName == "cookieclicker") then
    {
      # UPS will drain much faster
      "powerdevilrc"."BatteryManagement"."BatteryLowLevel".value = 42;
      "powerdevilrc"."BatteryManagement"."BatteryCriticalLevel".value = 32;

      "plasma-org.kde.plasma.desktop-appletsrc" = {
        "Containments][29][Applets][47][Configuration][Appearance" = {
          "autoFontAndSize".value = false;
          "fontFamily".value = "Noto Sans";
          "fontSize".value = 10;
          "fontStyleName".value = "Regular";
        };
        "Containments][54][Applets][72][Configuration][Appearance" = {
          "autoFontAndSize".value = false;
          "fontFamily".value = "Noto Sans";
          "fontSize".value = 10;
          "fontStyleName".value = "Regular";
        };
      };
    }
    else {};
  };
}
