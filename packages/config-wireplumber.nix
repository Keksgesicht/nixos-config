{ lib, stdenv }:

let
  wp-main-lua = "share/wireplumber/main.lua.d";
in
stdenv.mkDerivation {
  pname = "config-wireplumber";
  name = "config-wireplumber";
  src = ../files/packages/config-wireplumber;

  installPhase = ''
    mkdir -p $out/${wp-main-lua}
    cp -r $src/. $out/${wp-main-lua}/
    chmod +x $out/${wp-main-lua}/*.lua
  '';

  meta = with lib; {
    description = "Keksgesicht's wireplumber config files";
    platforms = platforms.all;
  };
}
