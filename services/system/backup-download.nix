{ pkgs, lib, hdd-mnt, ...}:

let
  bd-pkg = (pkgs.callPackage ../../packages/backup-download.nix {});

  bd-units = (sn: th: {
    services."backup-download@${sn}" = {
      path = [
        pkgs.gnutar
        pkgs.gzip
        pkgs.openssh
        pkgs.rsync
      ];
      description = "Generates Backups from different Remote Systems";
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = "${bd-pkg}/bin/backup-download.sh ${sn} ${th}";

        ProtectHome    = "read-only";
        ProtectProc    = "invisible";
        PrivateTmp     = "yes";
        ProtectClock   = "yes";
        PrivateDevices = "yes";

        ReadOnlyPaths = "/";
        TemporaryFileSystem = "/etc:ro";
        BindReadOnlyPaths = [
          "/etc/ssh/ssh_config"
        ];
        ReadWritePaths = "${hdd-mnt}/machines/${sn}";
      };
    };
    timers."backup-download@${sn}" = {
      enable = true;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        RandomizedDelaySec = "42min";
        AccuracySec = "1min";
        Persistent = "true";
      };
    };
  });
in
{
  systemd = lib.mkMerge [
    (bd-units "mailcow" "mail.keksgesicht.net")
    (bd-units "pihole" "rpi.pihole.local")
    ({
      tmpfiles.rules = [
        "q  ${hdd-mnt}/machines"
        "d  ${hdd-mnt}/machines/mailcow"
        "d  ${hdd-mnt}/machines/pihole"
      ];
    })
  ];

  /*
   * manual preparation steps:
   *   sudo -i
   *
   *   mkdir -p ~/.secrets/ssh
   *   ssh-keygen
   */
}


