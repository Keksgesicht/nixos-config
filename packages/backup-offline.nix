{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "offline-backup";
  name = "offline-backup";
  version = "1.0.0";
  src = ../files/packages/backup-offline;

  phases = [ "installPhase" "fixupPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,cfg}
    cp -r $src/bin/. $out/bin/
    cp -r $src/cfg/. $out/cfg/
  '';

  meta = with lib; {
    description = "Keksgesicht's scripts for copying important data to external storage";
    platforms = platforms.all;
  };
}
