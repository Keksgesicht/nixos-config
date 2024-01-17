{ config, pkgs, username, home-dir, ...}:

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
    #hunspell
    #hunspellDicts.en_US
    #hunspellDicts.de_DE
  ];

  fonts = {
    # https://nixos.wiki/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts
    # ln -s /run/current-system/sw/share/X11/fonts ~/.local/share/fonts
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-color-emoji
      # Noto + NerdFont => Noto-Nerdfonts
      (nerdfonts.override { fonts = [ "Noto" ]; })
      # Microsoft TrueType core fonts
      corefonts
      (pkgs.callPackage ../packages/my-fonts.nix {})
    ];
  };

  # https://nixos.wiki/wiki/Fonts#Using_bindfs_for_font_support
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems =
  let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [
        "resolve-symlinks"
        "x-gvfs-hide"
        "nofail"
        "ro"
      ];
    };
  in
  {
    "${xdg-data}/fonts" = mkRoSymBind "/run/current-system/sw/share/X11/fonts";
  };
}
