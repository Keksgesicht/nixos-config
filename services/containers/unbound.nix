{ config, pkgs, lib, ... }:

{
  systemd = {
    services = {
      "podman-unbound" = (import ./_stop_timeout.nix lib 17);
      "update-root-dns-servers" = {
        description = "Download root DNS server list";
        path = [
          pkgs.curl
          pkgs.nix
          pkgs.unixtools.xxd
        ];
        script = ''
          set -e
          set -o pipefail

          HASHFILE="/etc/unCookie/root-dns-server.hash"
          mkdir -p $(dirname $HASHFILE)

          URL="https://www.internic.net/domain/named.cache"
          NIX_STORE_FILE=$(nix-prefetch-url --print-path $URL | tail -n 1)
          HASH=$(sha256sum $NIX_STORE_FILE | cut -f1 -d' ' | xxd -r -p | base64)
          echo "sha256-$HASH" >$HASHFILE
        '';
      };
      "container-image-updater@unbound" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.jq
          pkgs.nix-prefetch-docker
          pkgs.skopeo
        ];
        environment = {
          IMAGE_UPSTREAM_HOST = "docker.io";
          IMAGE_UPSTREAM_NAME = "alpinelinux/unbound";
          IMAGE_UPSTREAM_TAG = "latest";
          IMAGE_FINAL_NAME = "localhost/alpinelinux-unbound";
          IMAGE_FINAL_TAG = "latest";
        };
      };
    };
    timers = {
      "update-root-dns-servers" = {
        enable = true;
        description = "Download root DNS server list";
        timerConfig = {
          OnCalendar = "monthly";
          RandomizedDelaySec = "42min";
          Persistent = "true";
        };
        wantedBy = [ "timers.target" ];
      };
      "container-image-updater@unbound" = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "timers.target" ];
      };
    };
  };

  virtualisation.oci-containers.containers = {
    "unbound" = {
      autoStart = true;
      dependsOn = [];

      # https://ryantm.github.io/nixpkgs/builders/images/dockertools/
      image = "localhost/unbound:latest";
      imageFile = pkgs.dockerTools.buildImage {
        name = "localhost/unbound";
        tag = "latest";

        fromImage = pkgs.dockerTools.pullImage (
          builtins.fromJSON (builtins.readFile "/etc/unCookie/containers/alpinelinux-unbound.json")
        );

        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [
            (pkgs.callPackage ../../packages/containers/unbound.nix {})
          ];
          pathsToLink = [
            "/scripts"
          ];
        };
        config = {
          Cmd = [ "/scripts/entrypoint.sh" ];
        };
      };

      ports = [
        "2053:53/tcp"
        "2053:53/udp"
      ];
      environment = {
        TZ = "Europe/Berlin";
      };
      volumes = [
        "/mnt/cache/appdata/unbound:/etc/unbound:Z"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.53.2"
        "--ip6" "fd00:172:23::aaaa:2"
        "--dns" "0.0.0.0"
      ];
    };
  };
}
