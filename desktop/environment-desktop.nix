{ pkgs, pkgs-latest, username, home-dir, ... }:

let
  xdg-data = "${home-dir}/.local/share";
  pkgs-unfree = pkgs-latest { config.allowUnfree = true; };
  key-layout = "us-altgr-weur";
in
{
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      # make GTK apps apply theming (flatpak)
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # https://nixos.wiki/wiki/KDE#GTK_themes_are_not_applied_in_Wayland_applications
  # desktop/home-manager/dconf.nix
  environment.sessionVariables = {
    GTK_USE_PORTAL    = "1";
    GTK_THEME_VARIANT = "dark";
  };

  users.users."${username}".packages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.de
  ] ++ (with kdePackages; [
    fcitx5-qt
    fcitx5-unikey
    fcitx5-configtool
  ]);

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    # Noto + NerdFont => Noto-Nerdfonts
    nerd-fonts.noto
    # Microsoft TrueType core fonts
    pkgs-unfree.corefonts
    # fonts I need (idk if duplicate)
    (callPackage ../packages/my-fonts.nix {})
  ];

  # https://nixos.wiki/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts
  fonts.fontDir.enable = true;
  systemd.user.tmpfiles.users."${username}".rules = [
    "L+ ${xdg-data}/fonts - - - - /run/current-system/sw/share/X11/fonts"
  ];

  # https://nixos.wiki/wiki/Fcitx5
  # https://www.youtube.com/watch?v=KW5tu-aBHh0
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
      ];
      settings.inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = key-layout;
          DefaultIM = "keyboard-${key-layout}";
        };
        "Groups/0/Items/0".Name = "keyboard-${key-layout}";
      };
    };
  };
}
