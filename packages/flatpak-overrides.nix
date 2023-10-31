{ stdenv, lib, bash, subversion }:

stdenv.mkDerivation {
  pname = "flatpak-overrides";
  name = "flatpak-overrides";
  version = "1.0.0";
  src = ../files/packages/flatpak-overrides;

  buildInputs = [ bash subversion ];
  installPhase = ''
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "Keksgesicht's flatpak overrides";
    platforms = platforms.all;
  };
}
