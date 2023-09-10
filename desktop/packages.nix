{ config, pkgs, ...}:

{
  users.users.keks.packages = with pkgs; [
    pdfgrep
    pympress
    qrencode
    waypipe
    wireguard-tools
    xorg.xlsclients
    #xorg-x11-server-Xephyr
    xorg.xrandr
    xscreensaver
    yubikey-manager
    keepassxc
    yt-dlp
  ];
}
