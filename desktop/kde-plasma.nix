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
      config.programs.kdeconnect.package
      # graphics info
      pkgs.clinfo
      pkgs.glxinfo
      pkgs.vulkan-tools
      pkgs.wayland-utils
    ];
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

  environment.etc."tmpfiles.d/ZZ-sddm-no-audio.conf".text =
  let
    dn = "/dev/null";
    sdUser = "/.config/systemd/user";
    sddmHome = "/var/lib/sddm";
  in ''
    d  ${sddmHome}/.config          0750 sddm sddm - -
    d  ${sddmHome}/.config/systemd  0750 sddm sddm - -
    d  ${sddmHome}${sdUser}         0750 sddm sddm - -
    L+ ${sddmHome}${sdUser}/pipewire.service       - - - - ${dn}
    L+ ${sddmHome}${sdUser}/pipewire.socket        - - - - ${dn}
    L+ ${sddmHome}${sdUser}/pipewire-pulse.service - - - - ${dn}
    L+ ${sddmHome}${sdUser}/pipewire-pulse.socket  - - - - ${dn}
    L+ ${sddmHome}${sdUser}/wireplumber.service    - - - - ${dn}
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
    }
    else if (config.networking.hostName == "cookieclicker") then
    {
      # UPS will drain much faster
      "powerdevilrc"."BatteryManagement"."BatteryLowLevel".value = 42;
      "powerdevilrc"."BatteryManagement"."BatteryCriticalLevel".value = 32;
    }
    else {};
  };
}
