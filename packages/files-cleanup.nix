{ pkgs, lib, stdenv, bash, }:

stdenv.mkDerivation {
  pname = "files-cleanup";
  name = "files-cleanup";
  version = "1.0.0";
  src = ../files/packages/files-cleanup;

  buildInputs = [ bash pkgs.gnused ];
  installPhase = ''
    mkdir -p $out/{bin,cfg}
    cp -r $src/bin/. $out/bin/
    cp -r $src/cfg/. $out/cfg/
    sed -i 's|/bin/rm|${pkgs.coreutils}/bin/rm|g' $out/bin/cleanup.sh
  '';

  meta = with lib; {
    description = "Keksgesicht's scripts to remove old files";
    platforms = platforms.all;
  };
}
