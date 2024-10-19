{ pkgs, hdd-name, hdd-mnt, ... }:

# https://docs.mailcow.email/
# https://github.com/mailcow/mailcow-dockerized
# https://www.youtube.com/playlist?list=PLcxL7iznHgfUHJyo4c0CMtaoFJ8S_9iVU

let
   mailcow-updater-script = "./update.sh --force";
   mailcow-srv-cfg = {
    after    = [ "mnt-${hdd-name}.mount" ];
    requires = [ "mnt-${hdd-name}.mount" ];
   };
   mailcow-path = "${hdd-mnt}/appdata2/mailcow";
   WorkingDirectory = "${mailcow-path}/docker";
   MAILCOW_BACKUP_LOCATION = "${mailcow-path}/backup";
in
{
  imports = [
    ../../system/containers/docker.nix
  ];

  environment.sessionVariables = {
    inherit MAILCOW_BACKUP_LOCATION;
  };

  systemd.services = {
    "mailcow-update" = mailcow-srv-cfg // {
      startAt = "Sat *-*-* 01:12:35";
      path = with pkgs; [
        bash curl docker gawk git iptables systemd
      ];
      script = ''
        ${mailcow-updater-script}
        if [ "$?" = 2 ]; then
          ${mailcow-updater-script}
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        inherit WorkingDirectory;
      };
    };
    "mailcow-backup" = mailcow-srv-cfg // {
      startAt = "*-*-* 06:06:06";
      path = with pkgs; [
        bash docker findutils gnugrep gnused which
      ];
      environment = {
        BACK_PARAMS = "backup all";
        BACK_OPTS = "--delete-days 3";
        inherit MAILCOW_BACKUP_LOCATION;
      };
      script = ''
        mkdir -p $MAILCOW_BACKUP_LOCATION
        helper-scripts/backup_and_restore.sh \
          $BACK_PARAMS $BACK_OPTS
      '';
      serviceConfig = {
        Type = "oneshot";
        inherit WorkingDirectory;
      };
    };
  };
}
