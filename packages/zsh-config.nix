{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "zsh-config";
  name = "zsh-config";
  version = "1.0.0";
  src = ../files/packages/zsh-config;

  installPhase = ''
    cp -r $src/. $out/
  '';

  meta = with lib; {
    description = "Keksgesicht's ZSH config (inspired by Manjaro)";
    platforms = platforms.all;
  };
}
