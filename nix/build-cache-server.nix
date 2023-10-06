{ config, pkgs, ... }:

{
  # https://nixos.wiki/wiki/Binary_Cache
  services.nix-serve = {
    enable = true;
    bindAddress = "127.0.0.1";
    port = 5000;
    openFirewall = false;
    secretKeyFile = "/var/nix-serve/secret-key.pem";
  };
}
