{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  environment.systemPackages = with pkgs; [
    bat
    bridge-utils
    dos2unix
    entr
    eza
    lm_sensors
    htop
    moreutils
    nano
    neofetch
    rename
    tldr
    wget
  ];
}
