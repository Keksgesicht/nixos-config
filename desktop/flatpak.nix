# file: packages/flatpak-flathub.nix

{ config, pkgs, ...}:

let
  flatpak-overrides = pkgs.callPackage ../packages/flatpak-overrides.nix {};
in
{
  environment.systemPackages = with pkgs; [
    (callPackage ../packages/flatpak-rollback.nix {})
  ];

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
          OnCalendar = "*-*-1,3,7,9,11,13,17,19,21,23,27,29 02:22:00";
          RandomizedDelaySec = "123min";
          Persistent = "true";
        };
        wantedBy = [ "timers.target" ];
      };
    };
  };

  # generate flatpak overrides by NixOS config
  systemd.tmpfiles.rules = [
    "L+ /var/lib/flatpak/overrides - - - - ${flatpak-overrides}"
  ];
}
