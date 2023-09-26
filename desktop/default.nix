# file: user/desktop.nix
# desc: focus on user specific settings for systems with DE/WM

{ config, pkgs, ...}:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account.
  # Don't forget to set a password with ‘passwd’.
  users.users.keks = {
    isNormalUser = true;
    description = "Jan B.";
    shell = pkgs.zsh;
    uid = 1000;
    group = "keks";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
  users.groups.keks = {
    gid = 1000;
  };

  imports = [
    ./audio.nix
    ./environment.nix
    ./flatpak.nix
    ./home-manager.nix
    ./kde-plasma.nix
    ./openssh.nix
    ./packages.nix
    ../services/user/xscreensaver.nix
  ];
}
