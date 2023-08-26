{ config, pkgs, ...}:

{
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
        imageDigest = "sha256:7a95fb31d906183b7181871d180b85f2195da6ab6ed7e23dbd77e440e0d1f4a2";
        sha256 = "sha256-/lfnKy9cpay7vIhaNwrKEi2mnfMSep1RWd0WnHOIiyw=";
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
        imageDigest = "sha256:e16184ec37826ccdc2ea104211196623177232bfb166f60048832ea5e75975f4";
        sha256 = "sha256-lDy+gFVOt26ocgafLEckULMKXwmqLkMvBjCER53t2sk=";
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


