{ stdenv, lib, bash }:

stdenv.mkDerivation {
  pname = "my-secrets";
  name = "my-secrets";
  version = "1.0.0";

  # TODO this directory has to exist
  src = /etc/nixos/secrets/local;

  buildInputs = [ bash ];
  installPhase = ''
    mkdir -p $out
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "Keksgesicht's semi secret data";
    platforms = platforms.all;
  };
}
