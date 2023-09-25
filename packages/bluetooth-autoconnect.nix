{ lib, pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "bluetooth-autoconnect";
  name = "bluetooth-autoconnect";
  version = "v1.3";

  # https://github.com/jrouleau/bluetooth-autoconnect
  src = fetchFromGitHub {
    owner = "jrouleau";
    repo = "bluetooth-autoconnect";
    rev = "9b6285367e1852290d2fe68a5001c8821955d140";
    sha256 = "sha256-qfU7fNPNRQxIxxfKZkGAM6Wd3NMuNI+8DqeUW+LYRUw=";
  };
  installPhase = ''
    cd $src
    install -Dm755 "bluetooth-autoconnect" \
          "$out/bin/bluetooth-autoconnect"
  '';

  meta = with lib; {
    description = "A linux command line tool to automatically connect to all paired and trusted bluetooth devices.";
    platforms = platforms.all;
  };
}
