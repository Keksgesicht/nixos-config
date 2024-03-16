{ config, pkgs, username, ... }:

let
  # python script which removes silent regions of videos with ffmpeg
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
  users.users."${username}".packages = with pkgs; [
    gnome-decoder
    gnome.gnome-calculator
    keepassxc
    meld
    nextcloud-client
    okteta
    qrencode
    silence-cutter
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
