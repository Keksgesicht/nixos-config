{ stdenv, lib }:

# nix-build -E 'with import <nixpkgs> {}; callPackage ./packages/my-audio.nix {}'
stdenv.mkDerivation {
  name = "my-audio";
  version = "1.0.0";
  src = ../files/packages/my-audio;

  phases = [ "installPhase" "fixupPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,lib,state}
    cp -r $src/bin/.   $out/bin/
    cp -r $src/lib/.   $out/lib/
    cp -r $src/state/. $out/state/
  '';

  meta = with lib; {
    description = "Keksgesicht's audio setup script collection";
    platforms = platforms.all;
  };
}
