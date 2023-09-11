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

  users.users."keks".packages = with pkgs.libsForQt5; [
    # use digital clock with PIM plugin
    akonadi-calendar
    kdepim-addons
    # additional KDE tools
    kalendar
    kate
    # security stuff
    ksshaskpass
  ];

  systemd.services = {
    /*
     * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogFilterPatterns=
     * https://forum.manjaro.org/t/stable-update-2023-06-04-kernels-gnome-44-1-plasma-5-27-5-python-3-11-toolchain-firefox/141610/3
     * do not log messages with the following regex
     */
    "user@" = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        LogFilterPatterns = [
          #"~QML"
          #"~QObject:"
          #"~QFont::"
          "~kwin_screencast: Dropping"
        ];
      };
    };
  };
}
