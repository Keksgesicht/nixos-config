{ pkgs, lib, ... }:

let
  inherit (lib.lists) forEach;

  name = "hot_backup";
  hot-list = [ 2 3 ];
  hot-name = (num: name + "_" + (builtins.toString num));
  hot-pkg = pkgs.callPackage ../../packages/backup-hot.nix {};
  hot-mount = "/mnt/${name}";

  ctab-opt = "nofail,tpm2-device=auto,no-read-workqueue,no-write-workqueue";
  ctab-tpm2 = (n: "${n} /dev/disk/by-label/${n} - ${ctab-opt}");
  req-crypt = (n: "x-systemd.requires=systemd-cryptsetup@${n}.service");

  timer-hot = {
    overrideStrategy = "asDropin";
    wantedBy = [ "timers.target" ];
  };
in
{
  environment.etc."crypttab".text = lib.strings.concatLines (
    forEach hot-list (e: ctab-tpm2 (hot-name e))
  );

  fileSystems."${hot-mount}" = {
    device = "/dev/disk/by-label/${name}";
    fsType = "btrfs";
    options = [
      "nofail"
      "compress-force=zstd:3"
      "x-systemd.device-timeout=123s" # prevent job removal
    ] ++ forEach hot-list (e: (req-crypt (hot-name e)));
  };

  KexOS.service."backup-hot@" = {
    service  = {
      stopIfChanged = false;
      restartIfChanged = false;
      after = [ "podman-pihole.service" ];
      description = "Hot Backup Job for %i";
      requires = [ "mnt-${name}.mount" ];
      path = with pkgs; [ rsync util-linux ];
      unitConfig = {
        RequiresMountsFor = hot-mount;
      };
      serviceConfig = {
        Type = "exec";
        ExecStart = "${hot-pkg}/bin/backup-hot.sh %i";
        ReadWritePaths = "${hot-mount}/data/%i";
        InaccessiblePaths = lib.mkForce [];
      };
    };
    timer.timerConfig.OnCalendar = "*-*-* 06:23:00";
  };
  systemd.timers = {
    "backup-hot@cookieflyer" = timer-hot;
    "backup-hot@cookiemailer" = timer-hot;
    "backup-hot@cookiepi" = timer-hot;
  };

  # usb device sometimes vanishes after snapshot
  systemd.services."usb-vanish-recovery" = {
    path = with pkgs; [ systemd util-linux ];
    script = ''
      sysreb() {
        systemctl --no-block reboot
      }
      mountpoint "${hot-mount}" || sysreb
      [ -d ${hot-mount}/backup_hot_backup/name/data/latest/ ] || sysreb
      exit 0
    '';
    startAt = "*-*-* 06:19:00";
  };
}
