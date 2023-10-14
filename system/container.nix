# file: packages/container.nix

{ config, pkgs, ...}:

{
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      dockerSocket.enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      autoPrune = {
        enable = true;
        dates = "Wed *-*-* 21:43:56";
        flags = [ "--all" ];
      };
    };

    containers = {
      enable = true;
      storage.settings = {
        storage = {
          driver = "btrfs";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
      containersConf.cniPlugins = [
        pkgs.cni-plugins
        pkgs.dnsname-cni
      ];
    };

    oci-containers.backend = "podman";
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    podman-compose
  ];

  environment.etc = {
    "containers/networks/server.json" = {
      source = ../files/linux-root/etc/containers/networks/server.json;
    };
  };
}
