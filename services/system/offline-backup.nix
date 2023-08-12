{ config, pkgs, ...}:

{
  systemd = {
    services = {
      # copy data to external storage
      "offline-backup@" = {
        description = "Offline Backup Job over %i";
        bindsTo = [
          "mnt-backup-%i-data.mount"
        ];
        unitConfig = {
          RequiresMountsFor = "/mnt/backup/%i/data";
          #ConsistsOf = "var-mnt-backup-%i-data.mount";
        };
        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.callPackage ../../packages/btrfs-snapshot.nix {}}/bin/backup-snapshot.sh %i";

          PrivateTmp   = "yes";
          ProtectHome  = "yes";
          ProtectClock = "yes";
          ProtectProc  = "invisible";

          ReadOnlyPaths  = "/";
          ReadWritePaths = "/mnt/backup/%i";
          #ExecPaths      = "/usr/bin";
          #SELinuxContext = "unconfined_u:unconfined_r:unconfined_t:s0";
        };
      };
      "offline-backup@USB" = {
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # overrides.conf (generated by Nix) resets PATH variable
        path = [
          pkgs.rsync
          pkgs.util-linux
        ];
      };
    };
  };
}
