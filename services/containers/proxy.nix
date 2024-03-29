{ config, pkgs, lib, ssd-mnt, ... }:

let
  cookie-pkg = (pkgs.callPackage ../../packages/unCookie.nix {});
  cc-dir = "${cookie-pkg}/containers";
in
{
  imports = [
    ../../system/container.nix
    ../system/server-and-config-update.nix
    ./container-image-updater.nix
  ];

  systemd = {
    services = {
      "podman-proxy" = (import ./podman-systemd-service.nix lib 25);
      "container-image-updater@proxy" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.nix-prefetch-docker
          pkgs.skopeo
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "linuxserver/swag";
          IMAGE_UPSTREAM_TAG = "latest";
          IMAGE_FINAL_NAME = "localhost/linuxserver-swag";
          IMAGE_FINAL_TAG = "latest";
        };
      };
      "server-and-config-update@CloudflareProxyIps" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.gnused
          pkgs.wget
        ];
        description = "Updates Cloudflares Proxy IPs for reverse proxy (swag)";
        serviceConfig = {
          ReadWritePaths = "${ssd-mnt}/appdata/swag/nginx";
          BindReadOnlyPaths = [
            "/etc/ssl"
            "/etc/static/ssl"
          ];
        };
      };
      "server-and-config-update@SwagCertbot" = {
        overrideStrategy = "asDropin";
        path = [ pkgs.podman ];
        description = "Renew SSL/TLS Certificate";
        serviceConfig = {
          ReadWritePaths = "/var/lib/containers/storage";
        };
      };
    };

    timers = {
      "container-image-updater@proxy" = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "timers.target" ];
      };
      "server-and-config-update@CloudflareProxyIps" = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "timers.target" ];
      };
      "server-and-config-update@SwagCertbot" = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "Wed *-*-* 20:20:00";
          RandomizedDelaySec = "5min";
        };
      };
    };
  };

  virtualisation.oci-containers.containers = {
    "proxy" = {
      autoStart = true;
      dependsOn = [ "pihole" ];

      image = "localhost/linuxserver-swag:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cc-dir}/linuxserver-swag.json")
      );

      environment = {
        TZ = config.time.timeZone;
        URL = "keksgesicht.net";
        EMAIL = "certbot@keksgesicht.net";
        SUBDOMAINS = "cloud,pihole,nix.mirror";
        ONLY_SUBDOMAINS = "true";
        VALIDATION = "dns";
        DNSPLUGIN = "cloudflare";
        # seconds to wait for DNS record propagation
        PROPAGATION = "42";
        STAGING = "false";
        PUID = "99";
        PGID = "200";
      };
      volumes = [
        "${ssd-mnt}/appdata/swag:/config:Z"
      ];
      extraOptions = [
        "--network" "host"
        "--dns" "172.23.53.2"
        "--dns" "fd00:172:23::aaaa:2"
        "--cap-add" "NET_ADMIN"
        "--cap-add" "NET_RAW"
      ];
    };
  };
}
