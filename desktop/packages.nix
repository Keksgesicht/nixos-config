{ config, pkgs, ...}:

{
  users.users.keks.packages = with pkgs; [
    pavucontrol
    pdfgrep
    pulseaudio
    pympress
    qpwgraph
    qrencode
    ventoy
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
