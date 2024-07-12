{ pkgs-stable, pkgs-latest, ... }:

let
  nix-reg = (name: pkgs: {
    from = { id = name; type = "indirect"; };
    to = { path = (builtins.toString (pkgs {}).path); type = "path"; };
  });
in

{
  nix.registry = {
    "pkgs-stable" = nix-reg "pkgs-stable" pkgs-stable;
    "pkgs-latest" = nix-reg "pkgs-latest" pkgs-latest;
  };
}
