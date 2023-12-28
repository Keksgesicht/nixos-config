{ stdenv, lib, bash }:

# nix-build -E 'with import <nixpkgs> {}; callPackage ./packages/my-audio.nix {}'
stdenv.mkDerivation {
  pname = "my-audio";
  name = "my-audio";
  version = "1.0.0";
  src = ../files/packages/my-audio;

  buildInputs = [ bash ];
  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp -r $src/bin/. $out/bin/
    cp -r $src/lib/. $out/lib/
  '';

  meta = with lib; {
    description = "Keksgesicht's audio setup script collection";
    platforms = platforms.all;
  };
}
