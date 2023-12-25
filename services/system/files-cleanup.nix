{ config, pkgs, ...}:

{
  systemd = {
    services = {
      "files-cleanup" = {
        description = "unCookie Cleanup";
        path = [
          pkgs.gawk
          pkgs.moreutils
          pkgs.plocate
          pkgs.podman
        ];
        after = [
          "mnt-main.mount"
          "mnt-array.mount"
          "mnt-ram.mount"
          "backup-snapshot@main.service"
          "backup-snapshot@array.service"
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
            "-/mnt/main/appdata/ddns"
            "-/mnt/ram/appdata3/pkgcache"

            "-/home/keks/.local/share/flatpak/overrides"
            "-/home/keks/.var/app/io.gitlab.librewolf-community/cache"
            "-/home/keks/.var/app/org.kde.kdenlive/cache"
            "-/home/keks/.var/app/org.mozilla.firefox/cache"

            "-/var/lib/containers/storage"
          ];
        };
      };

      # script in unit above needs updatedb/locate
      "update-locatedb" = {
        after = [
          "mnt-array.mount"
        ];
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
    interval = "08:15";
    package = pkgs.plocate;
    localuser = null;
    pruneNames = [
      # NixOS default
      # https://search.nixos.org/options?channel=unstable&show=services.locate.pruneNames
      ".bzr"
      ".cache"
      ".git"
      ".hg"
      ".svn"
      # my additional directory names
      "backup_array"
      "backup_main"
      "cache"
      "Cache"
      "CachedData"
      "CachedExtensions"
      "CachedExtensionVSIXs"
      "CachedProfilesData"
      "Code Cache"
      "DawnCache"
      "GPUCache"
      "GrShaderCache"
      "images-cache"
      "ShaderCache"
      "tabCache"
      "Trash"
    ];
  };
}
