{ stdenv, lib, nix-gitignore, bash, subversion }:

let
  patterns = ''
    *
    !flatpak-rollback.sh
  '';
in
stdenv.mkDerivation {
  pname = "flatpak-rollback";
  name = "flatpak-rollback";
  version = "1.0.0";
  src = nix-gitignore.gitignoreSourcePure patterns ../files/scripts;

  buildInputs = [ bash subversion ];
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -r ./* $out/bin/
  '';

  meta = with lib; {
    description = "Keksgesicht's scripts to revert one flatpak application to the next older version";
    platforms = platforms.all;
  };
}
