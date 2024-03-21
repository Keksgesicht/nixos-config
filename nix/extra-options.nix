{ config, pkgs, lib, system, ... }:

let
  inherit (lib) types;
  my-functions = (import ./my-functions.nix lib);
in
with my-functions;
{
  options = {
    nixpkgs.allowUnfreePackages = lib.mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  # allow packages with closed source code or paid products
  config.nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem
    (lib.getName pkg)
    (forEach config.nixpkgs.allowUnfreePackages (x: lib.getName x))
  );
}
