{ stdenv, lib, callPackage, makeWrapper
, bash, coreutils, gawk }:

let
  obs-cli = (callPackage ./obs-cli.nix {});
in
stdenv.mkDerivation {
  pname = "obs-hotkeys";
  name = "obs-hotkeys";
  version = "1.0.0";

  src = ../files/packages/obs-hotkeys;
  buildInputs = [ bash makeWrapper ];

  phases = [ "installPhase" "fixupPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,cfg}
    cp -r $src/bin/. $out/bin/
    cp -r $src/lib/. $out/lib/
    patchShebangs $out/bin/saveReplayBuffer.sh
    wrapProgram $out/bin/saveReplayBuffer.sh \
      --set PATH "${coreutils}/bin:${gawk}/bin:${obs-cli}/bin"
  '';

  meta = with lib; {
    description = "Keksgesicht's script for sending commands to obs-studio";
    platforms = platforms.all;
  };
}
