{ config, pkgs, ...}:

{
  virtualisation.oci-containers.containers = {
    proxy = {
      autoStart = true;
      dependsOn = [
        "pihole"
      ];

      image = "localhost/linuxserver-swag:latest";
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/linuxserver-swag";
        finalImageTag = "latest";
        imageName = "linuxserver/swag";
        imageDigest = "sha256:89b5c73c7cf33eb3fb301ab28fdaa785be3640ea4156efd1c35cdb3e6d1aeac4";
        sha256 = "sha256-ANSs+yFQlic7EnlGiGABbI2It1dbPUxFrVq7uhCxYZg=";
      };

      environment = {
        TZ = "Europe/Berlin";
        URL = "keksgesicht.net";
        EMAIL = "certbot@keksgesicht.net";
        SUBDOMAINS = "cloud,mirror,office,pihole";
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
        "/mnt/cache/appdata/swag:/config:Z"
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
}


