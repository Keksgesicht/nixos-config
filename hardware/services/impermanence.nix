{ config, pkgs, lib, inputs
, username, home-dir
, ssd-mnt, ssd-name
, hdd-mnt, hdd-name
, nvm-mnt, cookie-dir
, ... }:

let
  link-dir = "/mnt/user";

  etc-nmsc = "/etc/NetworkManager/system-connections";
  nm-state-file = "/var/lib/NetworkManager/NetworkManager.state";

  ssd-fs-cfg = config.fileSystems."${ssd-mnt}";
  ssd-fs-opt-str = (lib.concatStringsSep "," ssd-fs-cfg.options);
  biss = config.boot.initrd.systemd.services;
in
{
  boot.initrd.systemd = {
    storePaths = biss."setup-impermanence-root-volume".path;
    services = {
      "setup-impermanence-root-volume" = {
        description = "Setup new subvolume for /";
        unitConfig = {
          DefaultDependencies = false;
        };
        wantedBy = [ "initrd-root-device.target" ];
        after    = [ "initrd-root-device.target" ];
        before     = [ "initrd-root-fs.target" "sysroot.mount" ];
        requiredBy = [ "initrd-root-fs.target" "sysroot.mount" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = with pkgs; [
          btrfs-progs
          coreutils
          findutils
          tzdata
          util-linux
        ];
        environment =
        let
          tmp-mnt = "/mnt-${ssd-name}";
        in
        {
          TZ = config.time.timeZone;
          TZDIR = "${pkgs.tzdata}/share/zoneinfo";

          BACKUPS_DAYS = "3";
          TMP_MNT = "${tmp-mnt}";
          TMP_ROOT_DIR = "${tmp-mnt}/root";
          BACKUP_DIR = "${tmp-mnt}/backup_${ssd-name}/boot/root";
        };
        script = ''
          list_backups() {
            bck_dirs=$(realpath $BACKUP_DIR/* | sort -r | tail -n +$BACKUPS_DAYS)
            find $bck_dirs -maxdepth 0 -mtime +$BACKUPS_DAYS
          }
          delete_subvolumes() {
              IFS=$'\n'
              for sv in $(btrfs subvolume list -o "$1" | cut -d' ' -f9); do
                  btrfs subvolume delete /mnt-${ssd-name}/$sv
              done
              btrfs subvolume delete $1
          }

          mkdir -p $TMP_MNT
          mount -t ${ssd-fs-cfg.fsType} -o ${ssd-fs-opt-str} \
            ${ssd-fs-cfg.device} $TMP_MNT

          mkdir -p $BACKUP_DIR
          for sv in $(list_backups); do
            delete_subvolumes $sv
          done
          if [ -e $TMP_ROOT_DIR ]; then
            mv $TMP_ROOT_DIR $BACKUP_DIR/$(date +%Y%m%d_%H%M%S)
          fi

          btrfs subvolume create $TMP_ROOT_DIR
          umount $TMP_MNT
          exit 0
        '';
      };
    };
  };

  fileSystems =
  let
    mkBootBind = (dir: {
      device = "${ssd-mnt}${dir}";
      fsType = "none";
      options = [
        "bind"
        "nofail"
        "x-gvfs-hide"
      ];
      depends = [
        "${ssd-mnt}"
        "/"
      ];
      neededForBoot = true;
    });
  in
  {
    "/" = {
      device = ssd-fs-cfg.device;
      fsType = ssd-fs-cfg.fsType;
      options = [
        "subvol=root"
        "compress=zstd:3"
        "nodev"
        "nosuid"
      ];
    };
    "${etc-nmsc}" = mkBootBind "${etc-nmsc}";
  };

  # https://github.com/nix-community/impermanence
  environment.persistence = {
    # only start with:
    # /etc -> /mnt/main/etc (BTRFS subvolume)
    # /var -> /mnt/main/var (BTRFS subvolume)
    "${ssd-mnt}" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/etc/secureboot"
        "/etc/unCookie"
        "/var/lib/bluetooth"
        "/var/lib/flatpak"
        "/var/lib/rasdaemon"
        "/var/lib/systemd/backlight"
        "/var/lib/systemd/timers"
        "/var/lib/waydroid"
        "/var/log"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/var/nix-serve/public-key.pem"
        "/var/nix-serve/secret-key.pem"
      ];
    };

    # /root -> /mnt/main/home/root
    "${ssd-mnt}/home" = {
      hideMounts = true;
      directories = [
        "/root/.secrets/ssh"
      ];
      files = [
        "/root/.config/ssh/known_hosts"
        "/root/.zhistory"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    # essential
    "L+ ${link-dir}/etc  - - - - ${ssd-mnt}/etc"
    "L+ ${link-dir}/home - - - - ${ssd-mnt}/home"
    "L+ ${link-dir}/var  - - - - ${ssd-mnt}/var"
    # stuff
    "L+ ${link-dir}/backup_${hdd-name} - - - - ${hdd-mnt}/backup_${hdd-name}"
    "L+ ${link-dir}/backup_${ssd-name} - - - - ${ssd-mnt}/backup_${ssd-name}"
    "L+ ${link-dir}/appdata      - - - - ${ssd-mnt}/appdata"
    "L+ ${link-dir}/appdata2     - - - - ${hdd-mnt}/appdata2"
    "L+ ${link-dir}/appdata3     - - - - ${nvm-mnt}/appdata3"
    "L+ ${link-dir}/Games        - - - - ${nvm-mnt}/Games"
    "L+ ${link-dir}/homeBraunJan - - - - ${hdd-mnt}/homeBraunJan"
    "L+ ${link-dir}/homeGaming   - - - - ${hdd-mnt}/homeGaming"
    # useful subvolumes
    "q  ${ssd-mnt}/appdata  - - - - -"
    "q  ${hdd-mnt}/appdata2 - - - - -"
    "q  ${nvm-mnt}/appdata3 - - - - -"
    "q  ${nvm-mnt}/Games        0755 ${username} ${username} - -"
    "q  ${hdd-mnt}/homeBraunJan 0755 ${username} ${username} - -"
    "q  ${hdd-mnt}/homeGaming   0755 ${username} ${username} - -"
    # additional data
    "L+ ${link-dir}/binWin    - - - - ${ssd-mnt}/binWin"
    "L+ ${link-dir}/system    - - - - ${ssd-mnt}/system"
    "L+ ${link-dir}/resources - - - - ${hdd-mnt}/resources"
    "L+ ${link-dir}/vm        - - - - ${ssd-mnt}/vm"
    "L+ ${link-dir}/vm2       - - - - ${hdd-mnt}/vm2"

    # suppress warning/info after every reboot
    "f+ /var/db/sudo/lectured/1000 - - - - -"

    # reset permissions for NM connections
    "z ${etc-nmsc} 0700 root root -"
  ]
  # disable WLAN by default on desktop/tower
  ++ lib.optionals (config.networking.networkmanager.enable
                && (config.networking.hostName == "cookieclicker"))
  [
    "C  ${nm-state-file} - - - - ${inputs.self}/files/linux-root${nm-state-file}"
  ]
  ;
}
