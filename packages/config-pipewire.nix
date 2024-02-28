{ lib, stdenv }:

let
  pw-cfg-path = "share/pipewire/pipewire.conf.d";
in
stdenv.mkDerivation {
  pname = "config-pipewire";
  name = "config-pipewire";
  src = ../files/packages/config-pipewire;

  installPhase = ''
    mkdir -p $out/${pw-cfg-path}
    cp -r $src/. $out/${pw-cfg-path}/
  '';

  meta = with lib; {
    description = "Keksgesicht's pipewire config files";
    platforms = platforms.all;
  };
}
