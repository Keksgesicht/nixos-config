{ config, pkgs, lib, cookie-pkg, secrets-dir, hdd-mnt, hdd-name, ... }:

let
  cc-dir = "${cookie-pkg}/containers";
  sec-file = "${secrets-dir}/keys/containers/tandoor/ENV";
  bind-path = "${hdd-mnt}/appdata2/tandoor";
in
{
  imports = [
    ../../system/containers/podman.nix
    ./container-image-updater
  ];

  container-image-updater = {
    "tandoor-http" = {
      upstream.name = "nginx";
      upstream.tag = "mainline-alpine";
      final.name = "tandoor-http";
      final.tag = "latest";
    };
    "tandoor-web" = {
      upstream.name = "vabene1111/recipes";
      final.name = "tandoor-web";
    };
    "tandoor-db" = {
      upstream.name = "postgres";
      upstream.tag = "15-alpine";
      final.name = "tandoor-db";
      final.tag = "latest";
    };
  };

  systemd = {
    services =
    let
      serviceExtraConfig = {
        after = [
          "mnt-${hdd-name}.mount"
        ];
        requires = [
          "mnt-${hdd-name}.mount"
        ];
      };
    in
    {
      "podman-tandoor-http" = (import ./podman-systemd-service.nix lib 13) // serviceExtraConfig;
      "podman-tandoor-web" = (import ./podman-systemd-service.nix lib 17) // serviceExtraConfig;
      "podman-tandoor-db" = (import ./podman-systemd-service.nix lib 23) // serviceExtraConfig;
    };
  };

  # https://docs.tandoor.dev/install/docker/
  # https://github.com/TandoorRecipes/recipes
  virtualisation.oci-containers.containers = {
    "tandoor-http" = {
      autoStart = true;
      dependsOn = [ "tandoor-web" ];

      image = "localhost/tandoor-http:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cc-dir}/tandoor-http.json")
      );

      environment = {
        TZ = config.time.timeZone;
      };
      environmentFiles = [ sec-file ];
      volumes = [
        # Do not make this a bind mount, see https://docs.tandoor.dev/install/docker/#volumes-vs-bind-mounts
        "tandoor-nginx_config:/etc/nginx/conf.d:ro"
        "tandoor-staticfiles:/static:ro"
        "${bind-path}/mediafiles:/media:ro"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.219.1"
        "--ip6" "fd00:172:23::219:1"
        "--add-host" "web_recipes:172.23.219.2"
      ];
    };

    "tandoor-web" = {
      autoStart = true;
      dependsOn = [ "tandoor-db" ];

      image = "localhost/tandoor-web:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cc-dir}/tandoor-web.json")
      );

      environment = {
        TZ = config.time.timeZone;
      };
      environmentFiles = [ sec-file ];
      volumes = [
        # Do not make this a bind mount, see https://docs.tandoor.dev/install/docker/#volumes-vs-bind-mounts
        "tandoor-staticfiles:/opt/recipes/staticfiles"
        "tandoor-nginx_config:/opt/recipes/nginx/conf.d"
        "${bind-path}/mediafiles:/opt/recipes/mediafiles"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.219.2"
        "--ip6" "fd00:172:23::219:2"
      ];
    };

    "tandoor-db" = {
      autoStart = true;
      dependsOn = [];

      image = "localhost/tandoor-db:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cc-dir}/tandoor-db.json")
      );

      environment = {
        TZ = config.time.timeZone;
      };
      environmentFiles = [ sec-file ];
      volumes = [
        "${bind-path}/postgresql:/var/lib/postgresql/data"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.219.3"
        "--ip6" "fd00:172:23::219:3"
      ];
    };
  };
}
