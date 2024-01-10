{ lib, stdenv, fetchFromGitHub
, patchSet ? ""
}:

let
  pkgver  = "119.0";
  commit  = "fd72683abe15de5cf57574125b64879e809cf5c4";
  nixhash = "sha256-MAerYaRbaQBqS8WJ3eaq6uxVqQg8diymPbLCU72nDjM=";
in
stdenv.mkDerivation {
  pname = "arkenfox-user.js";
  name = "arkenfox user.js";
  version = "${pkgver}";

  # https://github.com/arkenfox/user.js
  src = fetchFromGitHub {
    owner = "arkenfox";
    repo = "user.js";
    rev = "${commit}";
    sha256 = "${nixhash}";
  };

  patches = []
  ++ lib.optionals (patchSet == "FireFox")
  [
    ../files/packages/arkenfox-user.js/chrome-userContent.css.patch
    ../files/packages/arkenfox-user.js/page-width-and-height.patch
    ../files/packages/arkenfox-user.js/shutdown-clear-history.patch
  ]
  ++ lib.optionals (patchSet == "LibreWolf")
  [
    ../files/packages/arkenfox-user.js/startup-page.patch
  ]
  ++ [
    ../files/packages/arkenfox-user.js/audio-volume.patch
  ];

  installPhase = ''
    mkdir -p $out
    cp LICENSE.txt $out/
    cp README.md $out/
    cp user.js $out/
  '';

  meta = with lib; {
    description = "Arkenfox user.js with custom patches";
    platforms = platforms.all;
  };
}
