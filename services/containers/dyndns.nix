{ config, pkgs, ...}:

{
  systemd = {
    services."container-image-updater@dyndns" = {
      overrideStrategy = "asDropin";
      path = [
        pkgs.jq
        pkgs.skopeo
        pkgs.unixtools.xxd
      ];
      environment = {
        IMAGE_UPSTREAM_HOST = "docker.io";
        IMAGE_UPSTREAM_NAME = "hotio/cloudflareddns";
        IMAGE_UPSTREAM_TAG = "latest";
        IMAGE_FINAL_NAME = "dyndns";
        IMAGE_FINAL_TAG = "latest";
      };
    };
    timers."container-image-updater@dyndns" = {
      enable = true;
      overrideStrategy = "asDropin";
      wantedBy = [ "timers.target" ];
    };
  };

  virtualisation.oci-containers.containers = {
    ddns-v4 = {
      autoStart = true;
      dependsOn = [];

      image = "localhost/dyndns:latest";
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/dyndns";
        finalImageTag = "latest";
        imageName = "docker.io/hotio/cloudflareddns";
        imageDigest = (import "/etc/unCookie/containers/hashes/dyndns/digest");
        sha256 = (builtins.readFile "/etc/unCookie/containers/hashes/dyndns/nix-store");
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


