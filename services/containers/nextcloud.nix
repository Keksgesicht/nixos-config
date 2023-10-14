{ config, pkgs, lib, ... }:

{
  systemd = {
    services = {
      "podman-nextcloud" = (import ./service-config.nix lib);
      "podman-nextcloud-cron" = (import ./service-config.nix lib);
      "podman-nextcloud-db" = (import ./service-config.nix lib);
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
    };
  };

  virtualisation.oci-containers.containers = {
    nextcloud = {
      autoStart = true;
      dependsOn = [
        "proxy"
        "nextcloud-db"
      ];

      image = "localhost/nextcloud:stable";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "/etc/unCookie/containers/nextcloud.json")
      );

      environment = {
        TZ = "Europe/Berlin";
        #REDIS_HOST = "172.23.82.2";
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

    nextcloud-cron = {
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

    nextcloud-db = {
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
        "/etc/nixos/secrets/packages/containers/nextcloud/MYSQL"
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
  };
}
