{ config, pkgs, lib, ... }:

{
  imports = [
    ../system/server-and-config-update.nix
  ];

  systemd = {
    services =
    let
      serviceExtraConfig = {
        after = [
          "mnt-array.mount"
        ];
        requires = [
          "mnt-array.mount"
        ];
      };
    in
    {
      "podman-nextcloud" = (import ./_stop_timeout.nix lib 23) // serviceExtraConfig;
      "podman-nextcloud-cron" = (import ./_stop_timeout.nix lib 25) // serviceExtraConfig;
      "podman-nextcloud-db" = (import ./_stop_timeout.nix lib 27);
      "podman-nextcloud-redis" = (import ./_stop_timeout.nix lib 27);
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
            "/mnt/array/appdata2/nextcloud"
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
        builtins.fromJSON (builtins.readFile "/etc/unCookie/containers/nextcloud.json")
      );

      environment = {
        TZ = "Europe/Berlin";
        #PHP_MEMORY_LIMIT = "512M";
      };
      volumes = [
        "/mnt/cache/appdata/nextcloud/www:/var/www/html"
        "/mnt/cache/appdata/nextcloud/log:/var/log/apache2:z"
        "/mnt/array/appdata2/nextcloud:/var/www/html/data"
        "/mnt/array/homeBraunJan:/mnt/external_storage/homeBraunJan:ro"
        "/mnt/array/homeGaming:/mnt/external_storage/homeGaming:ro"
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
        builtins.fromJSON (builtins.readFile "/etc/unCookie/containers/nextcloud.json")
      );

      entrypoint = "/cron.sh";
      environment = {
        TZ = "Europe/Berlin";
      };
      volumes = [
        "/mnt/cache/appdata/nextcloud/www:/var/www/html"
        "/mnt/array/appdata2/nextcloud:/var/www/html/data"
      ];
    };

    "nextcloud-db" = {
      autoStart = true;
      dependsOn = [];

      image = "localhost/nextcloud-db:10.5";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "/etc/unCookie/containers/nextcloud-db.json")
      );

      cmd = [
        "--transaction-isolation=READ-COMMITTED"
        "--binlog-format=ROW"
      ];
      environment = {
        TZ = "Europe/Berlin";
        MYSQL_DATABASE = "nextcloud";
        MYSQL_USER = "nextcloud";
      };
      environmentFiles = [
        "/etc/nixos/secrets/services/containers/nextcloud/MYSQL"
        "/etc/nixos/secrets/services/containers/nextcloud/MYSQL_ROOT"
      ];
      volumes = [
        "/mnt/cache/appdata/database/nextcloud:/var/lib/mysql:Z"
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
        builtins.fromJSON (builtins.readFile "/etc/unCookie/containers/nextcloud-redis.json")
      );

      /*
      cmd = [
        "redis-server"
        "--appendonly" "yes"
        "--requirepass" "$$\{REDIS_HOST_PASSWORD\}"
      ];
      */
      environment = {
        TZ = "Europe/Berlin";
      };
      environmentFiles = [
        "/etc/nixos/secrets/services/containers/nextcloud/REDIS"
      ];
      volumes = [
        "/mnt/cache/appdata/redis/nextcloud:/data"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.82.2"
        "--ip6" "fd00:172:23::443:2:2"
      ];
    };
  };
}
