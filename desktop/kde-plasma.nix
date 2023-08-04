# file: user/kde-plasma.nix
# desc: focus on user specific settings for systems with DE/WM
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

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    okular
    plasma-browser-integration
  ];

  users.users.keks.packages = with pkgs; [
    kalendar
    kate
  ];
}
