{ lib, pkgs-stable, ... }:

let
  pkgs = pkgs-stable {
    #config.allowUnfree = true;
  };
in
{
  # Enable CUPS to print documents.
  # https://nixos.wiki/wiki/Printing
  services.printing = {
    #enable = true;
    browsing = lib.mkForce false;
    openFirewall = lib.mkForce false;
    drivers = with pkgs; [
      gutenprint
    ];
  };
}
