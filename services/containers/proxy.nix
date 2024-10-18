{ inputs, config, pkgs, lib, cookie-pkg, ssd-mnt, ... }:

let
  cc-dir = "${cookie-pkg}/containers";
  bind-path = "${ssd-mnt}/appdata/swag";
  my-functions = (import "${inputs.self}/nix/my-functions.nix" lib);
in
with my-functions;
{
  imports = [
    ../../system/containers/podman.nix
    ../system/server-and-config-update.nix
    ./container-image-updater
  ];

  container-image-updater."proxy" = {
    upstream.name = "linuxserver/swag";
    final.name = "linuxserver-swag";
  };

  systemd = {
    services = {
      "podman-proxy" = (import ./podman-systemd-service.nix lib 25);
      "server-and-config-update@CloudflareProxyIps" = {
        overrideStrategy = "asDropin";
        path = [
          pkgs.gnused
          pkgs.wget
        ];
        description = "Updates Cloudflares Proxy IPs for reverse proxy (swag)";
        serviceConfig = {
          ReadWritePaths = "${bind-path}/nginx";
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
          BindReadOnlyPaths = "/etc/containers";
          ReadWritePaths = "/var/lib/containers/storage";
        };
      };
    };

    timers = {
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
        SUBDOMAINS =
          if (config.networking.hostName == "cookieclicker") then
            "wildcard,*.cookieclicker"
          else if (config.networking.hostName == "cookiepi") then
            "wildcard,*.cookiepi,cloud,tandoor.tb"
          else "";
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
        "${bind-path}:/config"
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

  systemd.tmpfiles.rules =
  let
    inCfg = "${inputs.self}/files/container-cfg/swag/nginx";
    eList = (forEach (listFilesRec inCfg) (e:
      let
        eFile = lib.removePrefix inCfg e;
      in
      "r ${bind-path}/nginx${eFile} - - - - -"
    ));
  in
  eList ++ [
    "C+ ${bind-path}/nginx - 99 200 - ${inCfg}"
  ];
}
