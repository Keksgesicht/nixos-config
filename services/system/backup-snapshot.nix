{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    (callPackage ../../packages/list-backups.nix {})
  ];

  systemd = {
    services = {
      # one snapshot a day
      "backup-snapshot@" = {
        description = "Online Backup Job (snapshot - %i)";
        after = [
          "mnt-%i.mount"
        ];
        serviceConfig = {
          Type      = "oneshot";
          ExecStart = "${pkgs.callPackage ../../packages/backup-snapshot.nix {}}/bin/backup-snapshot.sh %i";
          PrivateTmp   = "yes";
          ProtectHome  = "yes";
          ProtectClock = "yes";
          ProtectProc  = "invisible";

          #ExecPaths = "/usr/bin";
          #ExecPaths = "/usr/sbin";
          #SELinuxContext = "unconfined_u:unconfined_r:unconfined_t:s0";
        };
      };
      "backup-snapshot@main" = {
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # overrides.conf (generated by Nix) resets PATH variable
        path = [
          pkgs.btrfs-progs
          pkgs.gawk
          pkgs.util-linux
        ];
      };
      "backup-snapshot@array" = {
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # overrides.conf (generated by Nix) resets PATH variable
        path = [
          pkgs.btrfs-progs
          pkgs.gawk
          pkgs.util-linux
        ];
      };

      # each our one additional snapshot
      "backup-hourly@" = {
        description = "Online Backup Job (snapshot - %i)";
        after = [
          "mnt-%i.mount"
        ];
        serviceConfig = {
          Type      = "oneshot";
          ExecStart = "${pkgs.callPackage ../../packages/backup-snapshot.nix {}}/bin/backup-hourly.sh %i";
          PrivateTmp   = "yes";
          ProtectHome  = "yes";
          ProtectClock = "yes";
          ProtectProc  = "invisible";

          #ExecPaths = "/usr/bin";
          #ExecPaths = "/usr/sbin";
          #SELinuxContext = "unconfined_u:unconfined_r:unconfined_t:s0";
        };
      };
      "backup-hourly@main" = {
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # overrides.conf (generated by Nix) resets PATH variable
        path = [
          pkgs.btrfs-progs
          pkgs.gawk
          pkgs.util-linux
        ];
      };
      "backup-hourly@array" = {
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # overrides.conf (generated by Nix) resets PATH variable
        path = [
          pkgs.btrfs-progs
          pkgs.gawk
          pkgs.util-linux
        ];
      };
    };

    timers = {
      # one snapshot a day
      "backup-snapshot@" = {
        description = "Online Backup Timer (snapshot - %i)";
        timerConfig = {
          OnCalendar = "*-*-* 06:15:00";
          # also run when system was offline (like anacron)
          Persistent = "true";
        };
      };
      "backup-snapshot@main" = {
        # only for systemd unit masking
        enable = true;
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # this auto enables this unit in the context of systemd
        wantedBy = [ "timers.target" ];
      };
      "backup-snapshot@array" = {
        # only for systemd unit masking
        enable = true;
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # this auto enables this unit in the context of systemd
        wantedBy = [ "timers.target" ];
      };

      # each our one additional snapshot
      "backup-hourly@" = {
        description = "Online Backup Timer (snapshot - %i)";
        timerConfig = {
          OnCalendar = "*-*-* 06:15:00";
          # also run when system was offline (like anacron)
          Persistent = "true";
        };
      };
      "backup-hourly@main" = {
        # only for systemd unit masking
        enable = false;
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # this auto enables this unit in the context of systemd
        #wantedBy = [ "timers.target" ];
      };
      "backup-hourly@array" = {
        # only for systemd unit masking
        enable = false;
        # fixes empty config (extends template unit)
        overrideStrategy = "asDropin";
        # this auto enables this unit in the context of systemd
        #wantedBy = [ "timers.target" ];
      };
    };
  };
}
