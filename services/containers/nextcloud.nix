{ config, pkgs, ...}:

{
  systemd = {
    services = {
      "container-image-updater@nextcloud" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.skopeo
          pkgs.unixtools.xxd
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "nextcloud";
          IMAGE_UPSTREAM_TAG = "stable";
          IMAGE_FINAL_NAME = "nextcloud";
          IMAGE_FINAL_TAG = "stable";
        };
      };
      "container-image-updater@nextcloud-db" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.skopeo
          pkgs.unixtools.xxd
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "mariadb";
          IMAGE_UPSTREAM_TAG = "10.5";
          IMAGE_FINAL_NAME = "nextcloud-db";
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
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/nextcloud";
        finalImageTag = "stable";
        imageName = "nextcloud";
        imageDigest = (import "/etc/unCookie/containers/hashes/nextcloud/digest");
        sha256 = (builtins.readFile "/etc/unCookie/containers/hashes/nextcloud/nix-store");
      };

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
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/nextcloud";
        finalImageTag = "stable";
        imageName = "nextcloud";
        imageDigest = (import "/etc/unCookie/containers/hashes/nextcloud/digest");
        sha256 = (builtins.readFile "/etc/unCookie/containers/hashes/nextcloud/nix-store");
      };

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
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/nextcloud-db";
        finalImageTag = "10.5";
        imageName = "mariadb";
        imageDigest = (import "/etc/unCookie/containers/hashes/nextcloud-db/digest");
        sha256 = (builtins.readFile "/etc/unCookie/containers/hashes/nextcloud-db/nix-store");
      };

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


