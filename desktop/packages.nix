{ config, pkgs, ... }:

let
  vscut = (pkgs.callPackage ../packages/silence-cutter.nix {});
  vscut-wrapped = pkgs.writeShellScriptBin "silence_cutter.py" ''
    export PATH=$PATH:"${pkgs.ffmpeg}/bin"
    exec ${vscut}/bin/silence_cutter.py $@
  '';
  silence-cutter = pkgs.symlinkJoin {
    pname = "silence-cutter";
    name = "video-silence-cutter";
    paths = [
      vscut-wrapped
      vscut
    ];
  };
in
{
  users.users."keks".packages = with pkgs; [
    gnome.gnome-calculator
    keepassxc
    nextcloud-client
    pdfgrep
    pympress
    qrencode
    silence-cutter
    waypipe
    wireguard-tools
    xorg.xlsclients
    xorg.xorgserver
    xorg.xrandr
    yt-dlp
    yubikey-manager
  ];
}
