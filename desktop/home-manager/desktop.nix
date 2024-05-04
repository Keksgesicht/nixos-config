{ config, username, home-dir, ... }:

{
  home-manager = {
    users."${username}" = {
      imports = [
        ((import ./applications.desktop.nix) username)
        ((import ./autostart.nix) config username)
        ((import ./dconf.nix) home-dir)
        ./mimeapps.nix
      ];
    };
  };

  # starting too early will sync excluded directories
  systemd.user.services = {
    "app-com.nextcloud.desktopclient.nextcloud@autostart" = {
      overrideStrategy = "asDropin";
      after = [
        "home-${username}-Documents.mount"
        "home-${username}-Music.mount"
      ];
    };
  };
}
