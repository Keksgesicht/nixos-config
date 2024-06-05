{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "config-zsh";
  name = "config-zsh";
  src = ../files/packages/config-zsh;

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "Keksgesicht's ZSH config (inspired by Manjaro)";
    platforms = platforms.all;
  };
}
