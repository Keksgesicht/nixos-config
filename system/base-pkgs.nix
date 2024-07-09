{ pkgs, ... }:

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
    fastfetch
    lm_sensors
    moreutils
    nano
    rename
    tldr
    wget
  ];
}
