{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "my-fonts";
  name = "my-fonts";
  version = "1.0.0";
  src = ../files/packages/my-fonts;

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/fonts
    cp -r $src/. $out/share/fonts/
  '';

  meta = with lib; {
    description = "some fonts";
    platforms = platforms.all;
  };
}
