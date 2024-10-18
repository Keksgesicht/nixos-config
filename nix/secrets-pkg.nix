{ secrets-pkg, ... }:

{
  environment.etc = {
    "flake-output/my-secrets" = {
      source = secrets-pkg;
    };
  };
}
