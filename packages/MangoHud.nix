{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "MangoHud";
  name = "MangoHud";
  version = "1.0.0";
  src = ../files/packages/MangoHud;

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "Keksgesicht's MangoHud config";
    platforms = platforms.all;
  };
}
