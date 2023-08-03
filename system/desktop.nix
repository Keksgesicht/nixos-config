# file: system/desktop.nix
# desc: setup for desktop specific tools and services

{ config, pkgs, ...}:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  ###
  ### DE/WM
  ###

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
}
