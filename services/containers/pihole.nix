{ config, pkgs, lib, cookie-pkg, ssd-mnt, ... }:

let
  cc-dir = "${cookie-pkg}/containers";
in
{
  imports = [
    ../../system/containers/podman.nix
    ./container-image-updater
  ];

  container-image-updater."pihole" = {
    upstream.name = "pihole/pihole";
  };

  systemd.services."podman-pihole" = (import ./podman-systemd-service.nix lib 27);

  virtualisation.oci-containers.containers = {
    "pihole" = {
      autoStart = true;
      dependsOn = [ "unbound" ];

      image = "localhost/pihole:latest";
      imageFile = pkgs.dockerTools.pullImage (
        builtins.fromJSON (builtins.readFile "${cc-dir}/pihole.json")
      );

      ports = [
        "53:53/tcp"
        "53:53/udp"
        #"5353:5353/udp"
      ];
      environment = {
        TZ = config.time.timeZone;
        IPv6 = "True";
        ServerIP = "192.168.178.150";
        INTERFACE = "eth0";
        WEBUIBOXEDLAYOUT = "boxed";
      };
      volumes = [
        "${ssd-mnt}/appdata/pihole/cron.d/pihole:/etc/cron.d/pihole:z"
        "${ssd-mnt}/appdata/pihole/dnsmasq.d:/etc/dnsmasq.d:Z"
        "${ssd-mnt}/appdata/pihole/pihole:/etc/pihole:Z"
        #"/tmp/containers/pihole:/var/log"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.53.1"
        "--ip6" "fd00:172:23::aaaa:1"
        "--dns" "172.23.53.2"
        "--dns" "fd00:172:23::aaaa:2"
        "--cap-add" "CAP_CHOWN"
      ];
    };
  };
}
