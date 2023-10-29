{ config, pkgs, ...}:

{
  imports = [ ../system/server-and-config-update.nix ];

  systemd = {
    services."server-and-config-update@DownloadBackup" = {
      # fixes empty unit file (extends template unit)
      overrideStrategy = "asDropin";
      # overrides.conf (generated by Nix) resets PATH variable
      path = [
        pkgs.gzip
        pkgs.rsync
        pkgs.sudo
        pkgs.gnutar
      ];
      # extra changes
      description = "Generates Backups from different Remote Systems";
      serviceConfig = {
        ProtectHome = "read-only";
        BindReadOnlyPaths = [
          "/etc/passwd"
          "/etc/ssh/ssh_config"
        ];
        ReadWritePaths = "/mnt/array/homeBraunJan/Documents/BackUp";
        #SELinuxContext = "unconfined_u:unconfined_r:unconfined_t:s0";
      };
    };
    timers."server-and-config-update@DownloadBackup" = {
      # only for systemd unit masking
      enable = true;
      # fixes empty unit file (extends template unit)
      overrideStrategy = "asDropin";
      # this auto enables this unit in the system context
      wantedBy = [ "timers.target" ];
    };
  };
}


