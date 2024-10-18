{ config, pkgs, lib, ssd-mnt, cookie-pkg, secrets-dir, ... }:

let
  ddns-v6-file = ../../files/scripts/cloudflare-ddns-v6.sh;
  cc-dir = "${cookie-pkg}/containers";

  CF_HOSTS =
    if (config.networking.hostName == "cookieclicker") then
      "150.host.keksgesicht.net"
    else if (config.networking.hostName == "cookiepi") then
      "25.host.keksgesicht.net"
    else "";
  CF_ZONES = "keksgesicht.net";
in
{
  imports = [
    ../../system/containers/podman.nix
    ./container-image-updater
  ];

  container-image-updater."dyndns" = {
    upstream.name = "hotio/cloudflareddns";
  };

  systemd = {
    services = {
      "podman-ddns-v4" = (import ./podman-systemd-service.nix lib 13);
      "podman-ddns-v6" = (import ./podman-systemd-service.nix lib 13);
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
        inherit CF_HOSTS;
        inherit CF_ZONES;
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
        inherit CF_HOSTS;
        inherit CF_ZONES;
        DETECTION_MODE =
          if (config.networking.hostName == "cookieclicker") then
            "local:enp4s0"
          else if (config.networking.hostName == "cookiepi") then
            "local:enp0s31f6"
          else "local:eth0";
        MY_IPV6_SUFFIX =
          if (config.networking.hostName == "cookieclicker") then
            "3581:150:0:1"
          else if (config.networking.hostName == "cookiepi") then
            "3581:25:0:1"
          else "";
        PUID = "99";
        PGID = "400";
        UMASK = "002";
      };
      environmentFiles = [
        "${secrets-dir}/keys/containers/ddns/CF_APITOKEN"
      ];
      volumes = [
        "${ssd-mnt}/appdata/ddns/v6:/config:Z"
        "${ddns-v6-file}:/app/cloudflare-ddns.sh:Z,ro"
      ];
      extraOptions = [
        "--network" "host"
      ];
    };
  };
}
