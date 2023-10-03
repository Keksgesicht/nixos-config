{ config, pkgs, ...}:

{
  imports = [
    ./environment.nix
  ];

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
  environment.sessionVariables = {
    GTK_USE_PORTAL    = "1";
    GTK_THEME_VARIANT = "dark";
  };
}
