{ pkgs, ... }:

let
  secrets-pkg = (pkgs.callPackage ../packages/my-secrets.nix {});
in
{
  environment.etc = {
    "flake-output/my-secrets" = {
      source = secrets-pkg;
    };
  };
}
