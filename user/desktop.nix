# file: user/desktop.nix
# desc: focus on user specific settings for systems with DE/WM

{ config, pkgs, ...}:

{
  imports = [
    # $AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
    <home-manager/nixos>
  ];

  fonts = {
    # flatpak and DE
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Noto" ]; })
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.keks = {
    isNormalUser = true;
    description = "Jan B.";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      git
      kate
      kalendar
      kate
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
  };

  home-manager.users.keks = {
    # The home.stateVersion option does not have a default and must be set
    home.stateVersion = "18.09";

    home.sessionVariables = {
      AUTH = "sudo";
      XDG_RUNTIME_DIR = "/run/user/$UID";
    };
  };

  # enables ssh-agent
  # avoids retyping passwords everytime
  programs = {
    ssh.startAgent = true;
    ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
  };
  home-manager.users.keks.pam.sessionVariables = {
    SSH_AUTH_SOCK = "${builtins.getEnv "XDG_RUNTIME_DIR"}/ssh-agent";
  };
}
