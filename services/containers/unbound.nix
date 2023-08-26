{ config, pkgs, ...}:

{
  virtualisation.oci-containers.containers = {
    unbound = {
      autoStart = true;
      dependsOn = [];

      # https://ryantm.github.io/nixpkgs/builders/images/dockertools/
      image = "localhost/unbound:latest";
      imageFile = pkgs.dockerTools.buildImage {
        name = "unbound";
        tag = "latest";

        fromImage = pkgs.dockerTools.pullImage {
          imageName = "alpinelinux/unbound";
          finalImageTag = "latest";
          imageDigest = "sha256:a819ea26b0e15f79304b2a03096c8c1b474358cac1d6fe6b7c1351eefec067d7";
          sha256 = "sha256-lKbQ4vTDh0FMelC6XM0663orz8iL4y9/1foVONshGzw=";
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


