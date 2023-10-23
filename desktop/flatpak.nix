# file: packages/flatpak-flathub.nix

{ config, pkgs, ...}:

let
  flatpak-overrides = pkgs.callPackage ../packages/flatpak-overrides.nix {};
in
{
  # enable flatpak
  services.flatpak.enable = true;
  # add flathub as a flatpak repository
  /*
   * flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   * flatpak update
   */

  systemd = {
    services = {
      "flatpak-auto-update" = {
        description = "Updates Flatpak Apps und Runtimes";
        serviceConfig = {
          ExecStart = "${pkgs.flatpak}/bin/flatpak update --system --assumeyes --noninteractive";
          PrivateTmp  = "yes";
          ProtectHome = "yes";
          ProtectProc = "invisible";
          ReadOnlyPaths = "/";
          ReadWritePaths = [
            "/var/lib/flatpak"
            "/var/tmp"
          ];
        };
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };
    };
    timers = {
      "flatpak-auto-update" = {
        description = "Automatically updates Flatpak Apps und Runtimes";
        timerConfig = {
          OnCalendar = "*-*-* 02:22:00";
          RandomizedDelaySec = "123min";
          Persistent = "true";
        };
        wantedBy = [ "timers.target" ];
      };
    };
  };

  environment.etc = {
    "flatpak/overrides" = {
      source = "${flatpak-overrides}/etc/flatpak/overrides";
    };
  };
}
