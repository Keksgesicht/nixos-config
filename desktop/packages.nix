{ config, pkgs, ...}:

{
  users.users."keks".packages = with pkgs; [
    pdfgrep
    pympress
    qrencode
    waypipe
    wireguard-tools
    xorg.xlsclients
    xorg.xorgserver
    xorg.xrandr
    yubikey-manager
    keepassxc
    yt-dlp
  ];
}
