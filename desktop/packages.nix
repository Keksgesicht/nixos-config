{ config, pkgs, username, ... }:

{
  users.users."${username}".packages = with pkgs; [
    gnome-decoder
    gnome.gnome-calculator
    keepassxc
    meld
    nextcloud-client
    okteta
    qrencode
    (ventoy.override {
      withQt5 = (config.services.xserver.enable);
    })
    waypipe
    wireguard-tools
    xorg.xlsclients
    xorg.xorgserver
    xorg.xrandr
    yubikey-manager
  ];
}
