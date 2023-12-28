{ config, ... }:

{
  # base environment variables
  # https://nixos.wiki/wiki/Environment_variables
  # This is using a rec (recursive) expression to set and access XDG_BIN_HOME within the expression
  # For more on rec expressions see https://nix.dev/tutorials/first-steps/nix-language#recursive-attribute-set-rec
  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    #XDG_RUNTIME_DIR = "/run/user/$UID";

    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];
    AUTH = "sudo";

    # force usage of XDG directories
    GNUPGHOME     = "${XDG_CONFIG_HOME}/gnupg";
    GTK2_RC_FILES = "${XDG_CONFIG_HOME}/gtk-2.0/gtkrc";
    KDEHOME       = "${XDG_CONFIG_HOME}/kde";
    LESSHISTFILE  = "${XDG_CACHE_HOME}/lesshst";
    #XAUTHORITY    = "${XDG_RUNTIME_DIR}/Xauthority";
    #XINITRC       = "${XDG_CONFIG_HOME}/X11/xinitrc";
  };

  home-manager.users."keks" = {
    xdg.userDirs = {
      enable = true;
      desktop   = "$HOME/Desktop";
      documents = "/mnt/array/homeBraunJan/Documents";
      download  = "/mnt/array/homeBraunJan/Downloads";
      music     = "/mnt/array/homeBraunJan/Music";
      pictures  = "/mnt/array/homeBraunJan/Pictures";
      videos    = "/mnt/array/homeBraunJan/Videos";
      publicShare = "$HOME/Public";
      templates   = "$HOME/Templates";
    };
    xdg.configFile."user-dirs.locale".text = ''
      en_US
    '';
  };

  # git security
  environment.sessionVariables = rec {
    GIT_CEILING_DIRECTORIES = "/home:$HOME/git:/mnt:/mnt/array/homeBraunJan/Documents/development/git:/mnt/main/home/keks/git";
  };
}
