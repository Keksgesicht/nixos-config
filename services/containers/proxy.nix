{ config, pkgs, lib, ... }:

{
  systemd = {
    services = {
      "podman-proxy" = (import ./service-config.nix lib);
      "container-image-updater@proxy" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.skopeo
          pkgs.unixtools.xxd
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "linuxserver/swag";
          IMAGE_UPSTREAM_TAG = "latest";
          IMAGE_FINAL_NAME = "linuxserver-swag";
          IMAGE_FINAL_TAG = "latest";
        };
      };
    };
    timers."container-image-updater@proxy" = {
      enable = true;
      overrideStrategy = "asDropin";
      wantedBy = [ "timers.target" ];
    };
  };

  virtualisation.oci-containers.containers = {
    proxy = {
      autoStart = true;
      dependsOn = [];

      image = "localhost/linuxserver-swag:latest";
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/linuxserver-swag";
        finalImageTag = "latest";
        imageName = "linuxserver/swag";
        imageDigest = (import "/etc/unCookie/containers/hashes/linuxserver-swag/digest");
        sha256 = (builtins.readFile "/etc/unCookie/containers/hashes/linuxserver-swag/nix-store");
      };

      environment = {
        TZ = "Europe/Berlin";
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
        "/mnt/cache/appdata/swag:/config:Z"
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


