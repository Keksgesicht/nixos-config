{ stdenv, lib, bash, subversion }:

stdenv.mkDerivation {
  pname = "container-unbound";
  name = "container-unbound";
  version = "1.0.0";

  src = ../files/packages/containers/unbound;
  dnssrc = builtins.fetchurl {
    url = "https://www.internic.net/domain/named.cache";
    sha256 = "0xlssxh9vb0wir1ba1d26jr6mfcv8d0r05x3n9y5fx34dg5j74j0";
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
