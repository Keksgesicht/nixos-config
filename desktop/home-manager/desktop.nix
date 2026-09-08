{ config, username, home-dir, ... }:

let
  hn = config.networking.hostName;
in
{
  home-manager = {
    users."${username}" = {
      imports = [
        ((import ./applications.desktop.nix) config username)
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
      preStart = "sleep 42s";
      after = [
        "home-${username}-Documents.mount"
        "home-${username}-Music.mount"
        "home-${username}-Pictures.mount"
      ];
    };
  } // (if (hn == "cookieclicker") then {
    "app-Ferdium@autostart" = {
      overrideStrategy = "asDropin";
      preStart = "sleep 5s";
    };
  } else {});
}
