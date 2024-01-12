{ config, pkgs, lib, cookie-dir, secrets-dir
, ssd-mnt, hdd-mnt, hdd-name
, ... }:

{
  imports = [
    ../system/server-and-config-update.nix
  ];

  systemd = {
    services =
    let
      serviceExtraConfig = {
        after = [
          "mnt-${hdd-name}.mount"
        ];
        requires = [
          "mnt-${hdd-name}.mount"
        ];
      };
    in
    {
      "podman-nextcloud" = (import ./podman-systemd-service.nix lib 23) // serviceExtraConfig;
      "podman-nextcloud-cron" = (import ./podman-systemd-service.nix lib 25) // serviceExtraConfig;
      "podman-nextcloud-db" = (import ./podman-systemd-service.nix lib 27);
      "podman-nextcloud-redis" = (import ./podman-systemd-service.nix lib 27);
      "container-image-updater@nextcloud" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.nix-prefetch-docker
          pkgs.skopeo
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "nextcloud";
          IMAGE_UPSTREAM_TAG = "stable";
          IMAGE_FINAL_NAME = "localhost/nextcloud";
          IMAGE_FINAL_TAG = "stable";
        };
      };
      "container-image-updater@nextcloud-db" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.nix-prefetch-docker
          pkgs.skopeo
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "mariadb";
          IMAGE_UPSTREAM_TAG = "10.5";
          IMAGE_FINAL_NAME = "localhost/nextcloud-db";
          IMAGE_FINAL_TAG = "10.5";
        };
      };
      "container-image-updater@nextcloud-redis" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.nix-prefetch-docker
          pkgs.skopeo
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "redis";
          IMAGE_UPSTREAM_TAG = "latest";
          IMAGE_FINAL_NAME = "localhost/nextcloud-redis";
          IMAGE_FINAL_TAG = "latest";
        };
      };
      "server-and-config-update@NextcloudUpdates" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.podman
        ];
        description = "Update Nextcloud itself";
        serviceConfig = {
          ReadWritePaths = [
            "${hdd-mnt}/appdata2/nextcloud"
            "/var/lib/containers/storage"
          ];
        };
      };
    };

    timers = {
      "container-image-updater@nextcloud" = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "timers.target" ];
      };
      "container-image-updater@nextcloud-db" = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "timers.target" ];
      };
      "container-image-updater@nextcloud-redis" = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "timers.target" ];
      };
      "server-and-config-update@NextcloudUpdates" = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "timers.target" ];
      };
    };
  };

  virtualisation.oci-containers.containers = {
    "nextcloud" = {
      autoStart = true;
      dependsOn = [
        "nextcloud-db"
        "nextcloud-redis"
      ];

      image = "localhost/nextcloud:stable";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cookie-dir}/containers/nextcloud.json")
      );

      environment = {
        TZ = config.time.timeZone;
        APACHE_BODY_LIMIT = "4294967296"; # 4G
        #PHP_MEMORY_LIMIT = "512M";
      };
      volumes = [
        "${ssd-mnt}/appdata/nextcloud/www:/var/www/html"
        "${ssd-mnt}/appdata/nextcloud/log:/var/log/apache2:z"
        "${hdd-mnt}/appdata2/nextcloud:/var/www/html/data"
        "${hdd-mnt}/homeBraunJan:/mnt/external_storage/homeBraunJan:ro"
        "${hdd-mnt}/homeGaming:/mnt/external_storage/homeGaming:ro"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.80.2"
        "--ip6" "fd00:172:23::443:2"
        "--dns" "172.23.53.2"
        "--dns" "fd00:172:23::aaaa:2"
      ];
    };

    "nextcloud-cron" = {
      autoStart = true;
      dependsOn = [
        "nextcloud"
      ];

      image = "localhost/nextcloud:stable";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cookie-dir}/containers/nextcloud.json")
      );

      entrypoint = "/cron.sh";
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "${ssd-mnt}/appdata/nextcloud/www:/var/www/html"
        "${hdd-mnt}/appdata2/nextcloud:/var/www/html/data"
      ];
    };

    "nextcloud-db" = {
      autoStart = true;
      dependsOn = [];

      image = "localhost/nextcloud-db:10.5";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cookie-dir}/containers/nextcloud-db.json")
      );

      cmd = [
        "--transaction-isolation=READ-COMMITTED"
        "--binlog-format=ROW"
      ];
      environment = {
        TZ = config.time.timeZone;
        MYSQL_DATABASE = "nextcloud";
        MYSQL_USER = "nextcloud";
      };
      environmentFiles = [
        "${secrets-dir}/keys/containers/nextcloud/MYSQL"
        "${secrets-dir}/keys/containers/nextcloud/MYSQL_ROOT"
      ];
      volumes = [
        "${ssd-mnt}/appdata/database/nextcloud:/var/lib/mysql:Z"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.82.1"
        "--ip6" "fd00:172:23::443:2:1"
      ];
    };

    "nextcloud-redis" = {
      autoStart = true;
      dependsOn = [];

      image = "localhost/nextcloud-redis:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cookie-dir}/containers/nextcloud-redis.json")
      );

      /*
      cmd = [
        "redis-server"
        "--appendonly" "yes"
        "--requirepass" "$$\{REDIS_HOST_PASSWORD\}"
      ];
      */
      environment = {
        TZ = config.time.timeZone;
      };
      environmentFiles = [
        "${secrets-dir}/keys/containers/nextcloud/REDIS"
      ];
      volumes = [
        "${ssd-mnt}/appdata/redis/nextcloud:/data"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.82.2"
        "--ip6" "fd00:172:23::443:2:2"
      ];
    };
  };
}
