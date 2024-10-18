{ self, pkgs, lib, username, ...}:

{
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      dockerSocket.enable = true;
    };

    containers = {
      enable = true;
      storage.settings = {
        storage = {
          driver = lib.mkForce "btrfs";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
    };

    oci-containers.backend = "podman";
  };

  users.users."${username}".packages = with pkgs; [
    docker-compose
    podman-compose
  ];

  environment.etc = {
    "containers/networks/server.json" = {
      source = "${self}/files/linux-root/etc/containers/networks/server.json";
    };
  };
}
