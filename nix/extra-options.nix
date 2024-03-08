{ config, pkgs, lib, system, ... }:

let
  inherit (lib) types;
  my-functions = (import ./my-functions.nix lib);
in
with my-functions;
{
  options = {
    nixpkgs.allowUnfreePackages = lib.mkOption {
      type = with types; listOf (oneOf [ package str ]);
      default = [];
    };
  };

  # allow packages with closed source code or paid products
  config.nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem
    (lib.getName pkg)
    (forEach config.nixpkgs.allowUnfreePackages (x:
      if types.package.check x
      then lib.getName x
      else x
    ))
  );
}
