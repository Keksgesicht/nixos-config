# file: user/kde-plasma.nix
# desc: focus on user specific settings for systems with DE/WM
# https://nixos.wiki/wiki/KDE

{ config, pkgs, ...}:

{
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    displayManager.defaultSession = "plasmawayland";
  };

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    okular
    plasma-browser-integration
  ];

  users.users.keks = {
    packages = with pkgs; [
      kalendar
      kate
    ];
  };
}
