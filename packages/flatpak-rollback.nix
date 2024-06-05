{ stdenv, lib, nix-gitignore }:

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

  phases = [ "unpackPhase" "buildPhase" "installPhase" "fixupPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r ./* $out/bin/
  '';

  meta = with lib; {
    description = "Keksgesicht's scripts to revert one flatpak application to the next older version";
    platforms = platforms.all;
  };
}
