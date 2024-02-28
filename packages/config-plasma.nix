{ stdenv, lib }:

let
  pkgname = "config-plasma";
in
stdenv.mkDerivation {
  pname = "${pkgname}";
  name = "${pkgname}";
  src = ../files/packages/${pkgname};

  installPhase = ''
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "Keksgesicht's config files for his KDE Plasma desktop";
    platforms = platforms.all;
  };
}
