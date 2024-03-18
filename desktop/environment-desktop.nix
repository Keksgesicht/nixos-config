{ pkgs, username, home-dir, ... }:

let
  xdg-data = "${home-dir}/.local/share";
in
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

  users.users."${username}".packages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    aspellDicts.de
  ];

  fonts.packages = [
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    pkgs.noto-fonts-color-emoji
    # Noto + NerdFont => Noto-Nerdfonts
    (pkgs.nerdfonts.override {
      fonts = [ "Noto" ];
    })
    # Microsoft TrueType core fonts
    pkgs.corefonts
    # fonts I need (idk if duplicate)
    (pkgs.callPackage ../packages/my-fonts.nix {})
  ];

  # https://nixos.wiki/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts
  fonts.fontDir.enable = true;
  systemd.tmpfiles.rules = [
    "L+ ${xdg-data}/fonts - - - - /run/current-system/sw/share/X11/fonts"
  ];
}
