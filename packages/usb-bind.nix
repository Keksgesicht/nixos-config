{ stdenv, lib, bash, subversion }:

stdenv.mkDerivation {
  pname = "usb-bind";
  name = "usb-bind";
  version = "1.0.0";
  src = ../files/packages/usb-bind;

  buildInputs = [ bash subversion ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/bin/. $out/bin/
  '';

  meta = with lib; {
    description = "Script for shutting off power to USB devices";
    platforms = platforms.all;
  };
}
