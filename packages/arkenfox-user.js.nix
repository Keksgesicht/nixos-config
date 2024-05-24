{ lib, stdenv, fetchFromGitHub, patchSet ? "" }:

let
  pkgver  = "119.0";
  commit  = "fd72683abe15de5cf57574125b64879e809cf5c4";
  nixhash = "sha256-MAerYaRbaQBqS8WJ3eaq6uxVqQg8diymPbLCU72nDjM=";

  patchDir = ../files/packages/arkenfox-user.js;
  jsFile = "user.js";
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

  buildPhase = ''
    cp $src/${jsFile} ./
  ''
  + lib.strings.optionalString (patchSet == "FireFox") ''
    # page width and height
    sed -i '/"privacy.resistFingerprinting.letterboxing"/s|true|false|' ${jsFile}
    # shutdown clear history
    sed -i '/"browser.startup.page"/s|, .*);|, 3);|' ${jsFile}
    sed -i '/"privacy.clearOnShutdown.history"/s|true|false|' ${jsFile}
    # chrome userContent.css (Moodle)
    cat ${patchDir}/chrome-userContent.css.patch >> ${jsFile}
  ''
  + lib.strings.optionalString (patchSet == "LibreWolf") ''
    # startup page
    sed -i '/"browser.startup.page"/s|, .*);|, 1);|' ${jsFile}
    # audio volume
    cat ${patchDir}/audio-volume.patch >> ${jsFile}
  '';

  installPhase = ''
    mkdir -p $out
    cp ${jsFile} $out/
  '';

  meta = with lib; {
    description = "Arkenfox user.js with custom patches";
    platforms = platforms.all;
  };
}
