# file: system/environment.nix
# desc: time, locale, env vars, etc.

{ config, ...}:

{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS        = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT    = "de_DE.UTF-8";
      LC_MONETARY       = "de_DE.UTF-8";
      LC_NAME           = "de_DE.UTF-8";
      LC_NUMERIC        = "de_DE.UTF-8";
      LC_PAPER          = "de_DE.UTF-8";
      LC_TELEPHONE      = "de_DE.UTF-8";
      LC_TIME           = "de_DE.UTF-8";
    };
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "altgr-weur";
    xkbModel = "pc104";
    xkbVariant = "altgr-weur";
    # disable caps-lock key
    xkbOptions = "compose:menu,caps:none";
    extraLayouts."altgr-weur" = {
      description  = "English (Western European AltGr dead keys)";
      # US-Layout with typical European characters on AltGr combinations
      # file has been downloaded from https://altgr-weur.eu/
      symbolsFile  = ../files/linux-root/etc/X11/xkb/symbols/altgr-weur;
      languages    = [
        "dan"
        "nld"
        "eng"
        "fin"
        "fra"
        "deu"
        "ita"
        "nor"
        "por"
        "spa"
        "swe"
      ];
    };
  };
}
