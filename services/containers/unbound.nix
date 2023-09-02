{ config, pkgs, ...}:

{
  systemd = {
    services."container-image-updater@unbound" = {
      overrideStrategy = "asDropin";
      path = [
        pkgs.jq
        pkgs.skopeo
        pkgs.unixtools.xxd
      ];
      environment = {
        IMAGE_UPSTREAM_HOST = "docker.io";
        IMAGE_UPSTREAM_NAME = "alpinelinux/unbound";
        IMAGE_UPSTREAM_TAG = "latest";
        IMAGE_FINAL_NAME = "alpinelinux-unbound";
        IMAGE_FINAL_TAG = "latest";
      };
    };
    timers."container-image-updater@unbound" = {
      enable = true;
      overrideStrategy = "asDropin";
      wantedBy = [ "timers.target" ];
    };
  };

  virtualisation.oci-containers.containers = {
    unbound = {
      autoStart = true;
      dependsOn = [];

      # https://ryantm.github.io/nixpkgs/builders/images/dockertools/
      image = "localhost/unbound:latest";
      imageFile = pkgs.dockerTools.buildImage {
        name = "localhost/unbound";
        tag = "latest";

        fromImage = pkgs.dockerTools.pullImage {
          finalImageName = "localhost/alpinelinux-unbound";
          finalImageTag = "latest";
          imageName = "docker.io/alpinelinux/unbound";
          imageDigest = (import "/etc/unCookie/containers/hashes/alpinelinux-unbound/digest");
          sha256 = (builtins.readFile "/etc/unCookie/containers/hashes/alpinelinux-unbound/nix-store");
        };

        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [
            (pkgs.callPackage ../../packages/container-unbound.nix {})
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


