{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "btrfs-snapshot";
  name = "btrfs-snapshot";
  version = "1.0.0";
  src = ../files/packages/backup-snapshot;

  phases = [ "installPhase" "fixupPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,cfg}
    cp -r $src/bin/. $out/bin/
    cp -r $src/cfg/. $out/cfg/
  '';

  meta = with lib; {
    description = "Keksgesicht's scripts for BTRFS snaphots";
    platforms = platforms.all;
  };
}
