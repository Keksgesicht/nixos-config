{ inputs, config, pkgs, lib, ssd-mnt, ... }:

let
  cookie-dir = "/etc/unCookie";
  cookie-pkg = (pkgs.callPackage ../../packages/unCookie.nix {});
  cc-dir = "${cookie-pkg}/containers";

  bind-path = "${ssd-mnt}/appdata/unbound";
  my-functions = (import "${inputs.self}/nix/my-functions.nix" lib);
in
with my-functions;
{
  imports = [
    ../../system/container.nix
    ./container-image-updater
  ];

  container-image-updater."unbound" = {
    upstream.name = "alpinelinux/unbound";
    final.name = "alpinelinux-unbound";
  };

  systemd = {
    services = {
      "podman-unbound" = (import ./podman-systemd-service.nix lib 17) // {
        partOf = [ "NetworkManager.service" ];
      };
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

          HASHFILE="${cookie-dir}/root-dns-server.hash"
          mkdir -p $(dirname $HASHFILE)

          URL="https://www.internic.net/domain/named.cache"
          NIX_STORE_FILE=$(nix-prefetch-url --print-path $URL | tail -n 1)
          HASH=$(sha256sum $NIX_STORE_FILE | cut -f1 -d' ' | xxd -r -p | base64)
          echo "sha256-$HASH" | tee $HASHFILE
        '';
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
          builtins.fromJSON (builtins.readFile "${cc-dir}/alpinelinux-unbound.json")
        );

        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [
            (pkgs.callPackage ../../packages/containers/unbound.nix {
              inherit cookie-pkg;
            })
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
        TZ = config.time.timeZone;
      };
      volumes = [
        "${ssd-mnt}/appdata/unbound:/etc/unbound:Z"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.53.2"
        "--ip6" "fd00:172:23::aaaa:2"
        "--dns" "0.0.0.0"
      ];
    };
  };

  systemd.tmpfiles.rules =
  let
    inCfg = "${inputs.self}/files/container-cfg/unbound";
    eList = (forEach (listFilesRec inCfg) (e:
      let
        eFile = lib.removePrefix inCfg e;
      in
      "r ${bind-path}${eFile} - - - - -"
    ));

    kNetGen = (l: forEach l (eL: forEach eL.zone (eZ:
      ''
        local-zone: "${eZ.name}" ${eZ.type}
        local-data: "${eZ.name} 30 IN A ${eL.ip4}"
        local-data: "${eZ.name} 30 IN AAAA ${eL.ip6}"
      ''
    )));
    kNetText = kNetGen [
      { ip4 = "192.168.178.25"; ip6 = "fd00:3581::192:168:178:25"; zone = [
        { name = "cloud.keksgesicht.net"; type = "static"; }
        { name = "cookiepi.keksgesicht.net"; type = "redirect"; }
      ]; }
      { ip4 = "192.168.178.150"; ip6 = "fd00:3581::192:168:178:150"; zone = [
        { name = "games.keksgesicht.net"; type = "redirect"; }
        { name = "cookieclicker.keksgesicht.net"; type = "redirect"; }
      ]; }
    ];
    keksNetConf = pkgs.writeText "keksgesicht.net.conf" (
      lib.strings.concatStringsSep "\n" (flatList kNetText)
    );
  in
  eList ++ [
    "C+ ${bind-path} - 100 101 - ${inCfg}"
    "r  ${bind-path}/conf/keksgesicht.net.conf - - - - -"
    "C+ ${bind-path}/conf/keksgesicht.net.conf - 100 101 - ${keksNetConf}"
  ];

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 4194304;
  };
}
