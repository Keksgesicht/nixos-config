{ stdenv, lib, bash, subversion }:

# nix-build -E 'with import <nixpkgs> {}; callPackage ./packages/pkgs-init-audio.nix {}'
stdenv.mkDerivation {
  pname = "init-audio";
  name = "init-audio";
  version = "1.0.0";
  src = ../files/packages/init-audio;

  buildInputs = [ bash subversion ];
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
