{ config, pkgs, lib
, ssd-mnt, secrets-dir
, ... }:

let
  cookie-pkg = (pkgs.callPackage ../../packages/unCookie.nix {});
  cc-dir = "${cookie-pkg}/containers";
in
{
  imports = [
    ../../system/container.nix
    ./container-image-updater.nix
  ];

  systemd = {
    services = {
      "podman-ddns-v4" = (import ./podman-systemd-service.nix lib 13);
      "podman-ddns-v6" = (import ./podman-systemd-service.nix lib 13);
      "container-image-updater@dyndns" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.nix-prefetch-docker
          pkgs.skopeo
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "hotio/cloudflareddns";
          IMAGE_UPSTREAM_TAG = "latest";
          IMAGE_FINAL_NAME = "localhost/dyndns";
          IMAGE_FINAL_TAG = "latest";
        };
      };
    };
    timers."container-image-updater@dyndns" = {
      enable = true;
      overrideStrategy = "asDropin";
      wantedBy = [ "timers.target" ];
    };
  };

  virtualisation.oci-containers.containers = {
    "ddns-v4" = {
      autoStart = true;
      dependsOn = [ "pihole" ];

      image = "localhost/dyndns:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cc-dir}/dyndns.json")
      );

      environment = {
        TZ = config.time.timeZone;
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
        "${secrets-dir}/keys/containers/ddns/CF_APITOKEN"
      ];
      volumes = [
        "${ssd-mnt}/appdata/ddns/v4:/config:Z"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.53.4"
        "--ip6" "fd00:172:23::aaaa:4"
      ];
    };

    "ddns-v6" = {
      autoStart = true;
      dependsOn = [ "pihole" ];

      image = "localhost/dyndns:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cc-dir}/dyndns.json")
      );

      environment = {
        TZ = config.time.timeZone;
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
        "${secrets-dir}/keys/containers/ddns/CF_APITOKEN"
      ];
      volumes = [
        "${ssd-mnt}/appdata/ddns/v6:/config:Z"
        "${ssd-mnt}/appdata/ddns/v6-cloudflare-ddns.sh:/app/cloudflare-ddns.sh:Z,ro"
      ];
      extraOptions = [
        "--network" "host"
      ];
    };
  };
}
