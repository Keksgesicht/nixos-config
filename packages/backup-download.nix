{ stdenv, lib }:

stdenv.mkDerivation {
  name = "backup-download";
  src = ../files/packages/backup-download;

  phases = [ "installPhase" "fixupPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,cfg}
    cp -r $src/bin/. $out/bin/
    cp -r $src/cfg/. $out/cfg/
  '';

  meta = with lib; {
    description = "Copy important remote data to local strorage";
    platforms = platforms.all;
  };
}
