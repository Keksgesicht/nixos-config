{ stdenv, lib, nix-gitignore, bash }:

let
  patterns = ''
    *
    !list-backups.sh
  '';
in
stdenv.mkDerivation {
  pname = "list-backups";
  name = "list-backups";
  version = "1.0.0";
  src = nix-gitignore.gitignoreSourcePure patterns ../files/scripts;

  buildInputs = [ bash ];
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -r ./* $out/bin/
  '';

  meta = with lib; {
    description = "Keksgesicht's scripts to list the BTRFS snapshot to a given file";
    platforms = platforms.all;
  };
}
