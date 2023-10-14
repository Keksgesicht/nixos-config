{ config, pkgs, lib, ... }:

{
  systemd = {
    services = {
      "podman-lancache" = (import ./service-config.nix lib);
      "container-image-updater@lancache" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.nix-prefetch-docker
          pkgs.skopeo
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "lancachenet/monolithic";
          IMAGE_UPSTREAM_TAG = "latest";
          IMAGE_FINAL_NAME = "localhost/lancache-monolithic";
          IMAGE_FINAL_TAG = "latest";
        };
      };
    };
    timers."container-image-updater@lancache" = {
      enable = true;
      overrideStrategy = "asDropin";
      wantedBy = [ "timers.target" ];
    };
  };

  virtualisation.oci-containers.containers = {
    lancache = {
      autoStart = true;
      dependsOn = [
        "proxy"
      ];

      image = "localhost/lancache-monolithic:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "/etc/unCookie/containers/lancache-monolithic.json")
      );

      environment = {
        TZ = "Europe/Berlin";
        LANCACHE_IP = "192.168.178.150";
        UPSTREAM_DNS = "172.23.53.2";
        CACHE_MAX_AGE = "1234d";
        CACHE_MEM_SIZE = "1000m";
        CACHE_DISK_SIZE = "4321g";
        CACHE_SLICE_SIZE = "8m";
      };
      volumes = [
        "/mnt/ram/appdata3/lancache/data:/data/cache:Z"
        "/mnt/ram/appdata3/lancache/logs:/data/logs:Z"
        "/mnt/cache/appdata/lancache/cache-domains:/data/cachedomains:z"
        "lancache_www:/var/www:Z"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.80.4"
        "--ip6" "fd00:172:23::443:4"
        "--dns" "172.23.53.2"
        "--dns" "fd00:172:23::aaaa:2"
      ];
    };
  };
}
