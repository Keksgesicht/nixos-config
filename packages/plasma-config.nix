{ stdenv, lib }:

let
  pkgname = "plasma-config";
in
stdenv.mkDerivation {
  pname = "${pkgname}";
  name = "${pkgname}";
  version = "1.0.0";
  src = ../files/packages/${pkgname};

  buildInputs = [ ];
  installPhase = ''
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "Keksgesicht's config files for his KDE Plasma desktop";
    platforms = platforms.all;
  };
}
