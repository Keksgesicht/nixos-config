{ stdenv, lib, bash, subversion }:

stdenv.mkDerivation {
  pname = "files-cleanup";
  name = "files-cleanup";
  version = "1.0.0";
  src = ../files/packages/files-cleanup;

  buildInputs = [ bash subversion ];
  installPhase = ''
    mkdir -p $out/{bin,cfg}
    cp -r $src/bin/. $out/bin/
    cp -r $src/cfg/. $out/cfg/
  '';

  meta = with lib; {
    description = "Keksgesicht's scripts to remove old files";
    platforms = platforms.all;
  };
}
