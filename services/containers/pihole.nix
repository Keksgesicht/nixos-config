{ config, pkgs, ...}:

{
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
        imageName = "pihole/pihole";
        imageDigest = "sha256:8bc45afe1625487aef62859a5bf02f3d7b3429e480f4e29e4689635ab86ec312";
        sha256 = "sha256-AHNIbf/rvg26XhLzIxJgbhDuOUNNglB5rH9BaoIa/6s=";
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


