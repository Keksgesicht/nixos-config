{ stdenv, lib, bash }:

stdenv.mkDerivation {
  pname = "unCookie";
  name = "unCookie";
  version = "1.0.0";

  # TODO this directory has to exist
  src = /etc/unCookie;

  buildInputs = [ bash ];
  installPhase = ''
    mkdir -p $out
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "system state files";
    platforms = platforms.all;
  };
}
