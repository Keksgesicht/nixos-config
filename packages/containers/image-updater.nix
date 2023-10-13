{ stdenv, lib, bash, subversion }:

stdenv.mkDerivation {
  pname = "container-image-updater";
  name = "container-image-updater";
  version = "1.0.0";
  src = ../../files/packages/containers/image-updater;

  buildInputs = [ bash subversion ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/bin/. $out/bin/
  '';

  meta = with lib; {
    description = "Automatically bump up version hashes of container images";
    platforms = platforms.all;
  };
}
