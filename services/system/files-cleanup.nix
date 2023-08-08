{ config, pkgs, ...}:

{
  systemd = {
    services = {
      "files-cleanup" = {
        description = "unCookie Cleanup";
        path = [
          pkgs.gawk
          pkgs.plocate
          pkgs.podman
        ];
        after = [
          "mnt-cache.mount"
          "mnt-array.mount"
          "mnt-ram.mount"
          "backup_snapshot@cache.service"
          "backup_snapshot@array.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.callPackage ../../packages/files-cleanup.nix {}}/bin/cleanup.sh";

          PrivateTmp     = "yes";
          ProtectClock   = "yes";
          PrivateDevices = "yes";
          ProtectProc    = "invisible";

          ReadOnlyPaths = "/";
          #ExecPaths = "/usr/bin";

          ReadWritePaths = [
            "/mnt/array/homeBraunJan"

            "-/mnt/array/appdata2/nextcloud/janb/files/.Calendar-Backup"
            "-/mnt/array/appdata2/nextcloud/janb/files/.Contacts-Backup"
            "-/mnt/array/appdata2/nextcloud/janb/files/InstantUpload/SignalBackup"
            "-/mnt/cache/appdata/ddns"
            "-/mnt/ram/appdata3/pkgcache"

            "-/root/.cache"
            "-/root/.dbus"
            "-/root/.local"
            "-/home/keks/.cache"
            "-/home/keks/.var/app/io.gitlab.librewolf-community/cache"
            "-/home/keks/.var/app/org.kde.kdenlive/cache"
            "-/home/keks/.var/app/org.mozilla.firefox/cache"

            "-/var/lib/containers/storage"
          ];
        };
      };
    };

    timers = {
      # cleanup after boot and repeat after 24h (if still running)
      "files-cleanup" = {
        description = "unCookie Cleanup Timer";
        timerConfig = {
          OnBootSec         = "13s";
          OnUnitInactiveSec = "1d";
          AccuracySec       = "3s";
        };
        wantedBy = [
          "timers.target"
        ];
      };

      # script in unit above needs updatedb/locate
      update-locatedb = {
        timerConfig = {
          # also run when system was offline (like anacron)
          Persistent = "true";
        };
      };
    };
  };

  # script in unit above needs updatedb/locate
  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = null;
  };
}
