{ config, pkgs, ...}:

{
  imports = [
    # $AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
    <home-manager/nixos>
  ];
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
  programs.ssh = {
    startAgent = true;
    askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
  };
  home-manager.users.keks.pam.sessionVariables = {
    SSH_AUTH_SOCK = "${builtins.getEnv "XDG_RUNTIME_DIR"}/ssh-agent";
  };

  fonts = {
    # https://nixos.wiki/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts
    # ln -s /run/current-system/sw/share/X11/fonts ~/.local/share/fonts
    fontDir.enable = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      # Noto + NerdFont => Noto-Nerdfonts
      (nerdfonts.override { fonts = [ "Noto" ]; })
      # Microsoft TrueType core fonts
      corefonts
    ];
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      # make GTK apps apply theming (flatpak)
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  # https://nixos.wiki/wiki/KDE#GTK_themes_are_not_applied_in_Wayland_applications
  programs.dconf.enable = true;
}
