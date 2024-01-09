{ config, pkgs, home-dir, data-dir
, ssd-mnt, ssd-name
, hdd-mnt, hdd-name
, ...}:

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
          "mnt-${ssd-name}.mount"
          "mnt-${hdd-name}.mount"
          "backup-snapshot@${ssd-name}.service"
          "backup-snapshot@${hdd-name}.service"
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
            "${data-dir}"

            "-${hdd-mnt}/appdata2/nextcloud/janb/files/.Calendar-Backup"
            "-${hdd-mnt}/appdata2/nextcloud/janb/files/.Contacts-Backup"
            "-${hdd-mnt}/appdata2/nextcloud/janb/files/InstantUpload/SignalBackup"
            "-${ssd-mnt}/appdata/ddns"

            "-${home-dir}/.var/app/io.gitlab.librewolf-community/cache"
            "-${home-dir}/.var/app/org.kde.kdenlive/cache"
            "-${home-dir}/.var/app/org.mozilla.firefox/cache"

            "-/var/lib/containers/storage"
          ];
        };
      };

      # script in unit above needs updatedb/locate
      "update-locatedb" = {
        after = [
          "mnt-${hdd-name}.mount"
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
      "backup_${hdd-name}"
      "backup_${ssd-name}"
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
