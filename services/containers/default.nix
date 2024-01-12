{ config, ... }:

{
  imports = [
    # containers
    ./dyndns.nix
    ./lancache.nix
    ./nextcloud.nix
    ./pihole.nix
    ./proxy.nix
    ./unbound.nix
  ];
}
