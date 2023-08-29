{ config, pkgs, ...}:

{
  virtualisation.oci-containers.containers = {
    ddns-v4 = {
      autoStart = true;
      dependsOn = [];

      image = "localhost/dyndns:latest";
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/dyndns";
        finalImageTag = "latest";
        imageName = "hotio/cloudflareddns";
        imageDigest = "sha256:389d6a4d0508695d981950cf28a7e61118f378d5e1f4d033fb3fb7db793f0d7d";
        sha256 = "sha256-ffTLfzIZPP7HA8WVZyCdWUuHR0pNxHB4t3i0sMo0Z2c=";
      };

      environment = {
        TZ = "Europe/Berlin";
        LOG_LEVEL = "2";
        INTERVAL = "1000";
        CF_RECORDTYPES = "A";
        CF_HOSTS = "keksgesicht.net";
        CF_ZONES = "keksgesicht.net;keksgesicht.net";
        DETECTION_MODE = "dig-whoami.cloudflare";
        PUID = "99";
        PGID = "400";
        UMASK = "002";
      };
      environmentFiles = [
        "/etc/nixos/secrets/packages/containers/ddns/CF_APITOKEN"
      ];
      volumes = [
        "/mnt/cache/appdata/ddns/v4:/config:Z"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.53.4"
        "--ip6" "fd00:172:23::aaaa:4"
      ];
    };

    ddns-v6 = {
      autoStart = true;
      dependsOn = [];

      image = "localhost/dyndns:latest";

      environment = {
        TZ = "Europe/Berlin";
        LOG_LEVEL = "2";
        INTERVAL = "1000";
        CF_RECORDTYPES = "AAAA";
        CF_HOSTS = "keksgesicht.net";
        CF_ZONES = "keksgesicht.net;keksgesicht.net";
        DETECTION_MODE = "local:enp4s0";
        PUID = "99";
        PGID = "400";
        UMASK = "002";
      };
      environmentFiles = [
        "/etc/nixos/secrets/packages/containers/ddns/CF_APITOKEN"
      ];
      volumes = [
        "/mnt/cache/appdata/ddns/v6:/config:Z"
        "/mnt/cache/appdata/ddns/v6-cloudflare-ddns.sh:/app/cloudflare-ddns.sh:Z,ro"
      ];
      extraOptions = [
        "--network" "host"
      ];
    };
  };
}


