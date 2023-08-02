# file: packages/container.nix

{ config, pkgs, ...}:

{
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      # For Nixos version > 22.11
      #defaultNetwork.settings = {
      #  dns_enabled = true;
      #};
    };
  };

  environment.systemPackages = with pkgs; [
    #containernetworking-plugins
    docker-compose
    podman-compose
  ];
}
