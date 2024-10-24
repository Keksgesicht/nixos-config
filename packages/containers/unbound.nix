{ stdenv, lib, cookie-pkg }:

stdenv.mkDerivation {
  pname = "container-unbound";
  name = "container-unbound";
  version = "1.0.0";

  src = ../../files/packages/containers/unbound;
  dnssrc = builtins.fetchurl {
    url = "https://www.internic.net/domain/named.cache";
    sha256 = (builtins.readFile "${cookie-pkg}/root-dns-server.hash");
  };

  phases = [ "unpackPhase" "installPhase" ];
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
