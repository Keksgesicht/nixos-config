{ stdenv, lib, bash, subversion }:

stdenv.mkDerivation {
  pname = "container-unbound";
  name = "container-unbound";
  version = "1.0.0";

  src = ../files/packages/containers/unbound;
  dnssrc = builtins.fetchurl {
    url = "https://www.internic.net/domain/named.cache";
    sha256 = "sha256:09nvhzd2dx4agx4p0978scz2d3ab80rabv44iwczm66v1cdc5i8i";
  };

  buildInputs = [ bash subversion ];
  installPhase = ''
    mkdir -p $out/scripts
    cp -r $src/. $out/scripts/
    ln -s $dnssrc $out/scripts/root.hints
  '';

  meta = with lib; {
    description = "Unbound setup in container";
    platforms = platforms.all;
  };
}
