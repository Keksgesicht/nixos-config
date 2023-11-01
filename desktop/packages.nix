{ config, pkgs, ...}:

{
  users.users."keks".packages = with pkgs; [
    gnome.gnome-calculator
    keepassxc
    nextcloud-client
    pdfgrep
    pympress
    qrencode
    waypipe
    wireguard-tools
    xorg.xlsclients
    xorg.xorgserver
    xorg.xrandr
    yt-dlp
    yubikey-manager
  ];
}
