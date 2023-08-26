{ config, pkgs, ...}:

{
  virtualisation.oci-containers.containers = {
    lancache = {
      autoStart = true;
      dependsOn = [
        "proxy"
      ];

      image = "localhost/lancache-monolithic:latest";
      imageFile = pkgs.dockerTools.pullImage {
        finalImageName = "localhost/lancache-monolithic";
        finalImageTag = "latest";
        imageName = "lancachenet/monolithic";
        imageDigest = "sha256:b72d6b909b9e3fb7b521e90aab97479f7977bf6bee97e89a095e1afdbd6d3b85";
        sha256 = "sha256-LdFeYHJrIM+BAN+oAMQ69oTfP7/KLvOF0HPknD/ZFWo=";
      };

      environment = {
        TZ = "Europe/Berlin";
        LANCACHE_IP = "192.168.178.150";
        UPSTREAM_DNS = "172.23.53.2";
        CACHE_MAX_AGE = "1234d";
        CACHE_MEM_SIZE = "1000m";
        CACHE_DISK_SIZE = "4321g";
        CACHE_SLICE_SIZE = "8m";
      };
      volumes = [
        "/mnt/ram/appdata3/lancache/data:/data/cache:Z"
        "/mnt/ram/appdata3/lancache/logs:/data/logs:Z"
        "/mnt/cache/appdata/lancache/cache-domains:/data/cachedomains:z"
        "lancache_www:/var/www:Z"
      ];
      extraOptions = [
        "--network" "server"
        "--ip" "172.23.80.4"
        "--ip6" "fd00:172:23::443:4"
        "--dns" "172.23.53.2"
        "--dns" "fd00:172:23::aaaa:2"
      ];
    };
  };
}


