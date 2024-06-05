{ stdenv, lib, }:

stdenv.mkDerivation {
  pname = "flatpak-overrides";
  name = "flatpak-overrides";
  version = "1.0.0";
  src = ../files/packages/flatpak-overrides;

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "Keksgesicht's flatpak overrides";
    platforms = platforms.all;
  };
}
