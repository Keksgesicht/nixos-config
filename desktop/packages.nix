{ config, pkgs, username, ... }:

let
  arkenfox-ff = (pkgs.callPackage ../packages/arkenfox-user.js.nix {
    patchSet = "FireFox";
  });
  arkenfox-lw = (pkgs.callPackage ../packages/arkenfox-user.js.nix {
    patchSet = "LibreWolf";
  });

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
    copyq
    gnome.gnome-calculator
    keepassxc
    meld
    nextcloud-client
    #pdfdiff
    pdfgrep
    pympress
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
    yt-dlp
    yubikey-manager
  ];

  systemd.tmpfiles.rules = [
    "L+ /usr/share/arkenfox/FireFox   - - - - ${arkenfox-ff}"
    "L+ /usr/share/arkenfox/LibreWolf - - - - ${arkenfox-lw}"
  ];
}
