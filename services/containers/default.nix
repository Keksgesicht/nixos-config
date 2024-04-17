{ config, ... }:

{
  imports = [
    # containers
    ./lancache.nix
    ./pihole.nix
    ./proxy.nix
    ./unbound.nix
  ];
}
