{ stdenv, lib, bash }:

stdenv.mkDerivation {
  pname = "server-and-config-update";
  name = "server-and-config-update";
  version = "1.0.0";
  src = ../files/packages/server-and-config-update;

  buildInputs = [ bash ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/bin/. $out/bin/
  '';

  meta = with lib; {
    description = "Scripts to automate certain actions";
    platforms = platforms.all;
  };
}
