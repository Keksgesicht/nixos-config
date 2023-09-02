{ config, pkgs, ...}:

{
  systemd = {
    services."container-image-updater@pihole" = {
      overrideStrategy = "asDropin";
      path = [
        pkgs.jq
        pkgs.skopeo
        pkgs.unixtools.xxd
      ];
      environment = {
        IMAGE_UPSTREAM_HOST = "docker.io";
        IMAGE_UPSTREAM_NAME = "pihole/pihole";
        IMAGE_UPSTREAM_TAG = "latest";
        IMAGE_FINAL_NAME = "pihole";
        IMAGE_FINAL_TAG = "latest";
      };
    };
    timers."container-image-updater@pihole" = {
      enable = true;
      overrideStrategy = "asDropin";
      wantedBy = [ "timers.target" ];
    };
  };

  virtualisation.oci-containers.containers = {
    pihole = {
      autoStart = true;
      dependsOn = [
        "unbound"
      ];

      image = "localhost/pihole:latest";
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/pihole";
        finalImageTag = "latest";
        imageName = "docker.io/pihole/pihole";
        imageDigest = (import "/etc/unCookie/containers/hashes/pihole/digest");
        sha256 = (builtins.readFile "/etc/unCookie/containers/hashes/pihole/nix-store");
      };

      ports = [
        "192.168.178.150:53:53/tcp"
        "192.168.178.150:53:53/udp"
        #"5353:5353/udp"
      ];
      environment = {
        TZ = "Europe/Berlin";
        IPv6 = "True";
        ServerIP = "192.168.178.150";
        INTERFACE = "eth0";
        WEBUIBOXEDLAYOUT = "boxed";
      };
      volumes = [
        "/mnt/cache/appdata/pihole/cron.d/pihole:/etc/cron.d/pihole:z"
        "/mnt/cache/appdata/pihole/dnsmasq.d:/etc/dnsmasq.d:Z"
        "/mnt/cache/appdata/pihole/pihole:/etc/pihole:Z"
        #"/tmp/containers/pihole:/var/log"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.53.1"
        "--ip6" "fd00:172:23::aaaa:1"
        "--dns" "172.23.53.2"
        "--dns" "fd00:172:23::aaaa:2"
        # /mnt/cache/appdata/pihole/dnsmasq.d/99-upstream-dns-server.conf
        "--cap-add" "CAP_CHOWN"
      ];
    };
  };
}


