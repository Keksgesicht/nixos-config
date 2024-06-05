{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "config-fancontrol";
  name = "config-fancontrol";
  src = ../files/packages/config-fancontrol;

  phases = [ "installPhase" "fixupPhase" ];
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
