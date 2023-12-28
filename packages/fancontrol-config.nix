{ stdenv, lib, bash }:

stdenv.mkDerivation {
  pname = "fancontrol-config";
  name = "fancontrol-config";
  version = "1.0.0";
  src = ../files/packages/fancontrol-config;

  buildInputs = [ bash ];
  installPhase = ''
    mkdir -p $out/{bin,cfg}
    cp -r $src/bin/. $out/bin/
    cp -r $src/cfg/. $out/cfg/
  '';

  meta = with lib; {
    description = "Adjust fancontrol config to hwmon naming";
    platforms = platforms.all;
  };
}
