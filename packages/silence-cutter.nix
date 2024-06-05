{ lib, pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "silence-cutter";
  name = "video-silence-cutter";

  # https://github.com/DarkTrick/python-video-silence-cutter
  src = fetchFromGitHub {
    owner = "DarkTrick";
    repo = "python-video-silence-cutter";
    rev = "cad9577cc123146b0f83e203ffa7f7a50bfa2616";
    sha256 = "sha256-hOXFPbDOfCtlhg9JBc6Whf0oIgm5CeLoduLFaE1PYdM=";
  };
  buildInputs = with pkgs; [
    makeWrapper
    gnused
    python3
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  installPhase = ''
    cd $src
    install -Dm755 "silence_cutter.py" "$out/bin/silence_cutter.py"
    sed -i '1s|^|#!${pkgs.python3}/bin/python3\n|' "$out/bin/silence_cutter.py"
    wrapProgram "$out/bin/silence_cutter.py" \
      --prefix PATH ':' "${lib.makeBinPath [ pkgs.ffmpeg ]}" \
  '';

  meta = with lib; {
    description = "Python script removing silence moments in videos using ffmpeg";
    platforms = platforms.all;
  };
}
