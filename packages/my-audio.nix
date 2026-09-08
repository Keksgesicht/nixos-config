{ secrets-pkg, pkgs, lib, ... }:

let
  bt-dev-path = "${secrets-pkg}/wireless/bt-dev";
  rf = builtins.readFile;
  rep-col = (str: builtins.replaceStrings [":"] ["_"] str);
  rem-suf = (str: lib.removeSuffix "\n" str);
  bt2str = (file: rem-suf (rep-col (rf file)));
  MY_BT_DEV_IN_EAR_01     = bt2str "${bt-dev-path}/in-ears_01";
  MY_BT_DEV_IN_EAR_02     = bt2str "${bt-dev-path}/in-ears_02";
  MY_BT_DEV_OVER_THE_EARS = bt2str "${bt-dev-path}/over-the-ears";
in
{
  KexOS.packages."my-audio" = pkgs.stdenv.mkDerivation {
    name = "my-audio";
    version = "1.0.0";
    src = ../files/packages/my-audio;

    phases = [ "installPhase" "fixupPhase" ];
    installPhase = ''
      mkdir -p $out/{bin,lib,state}
      cp -r $src/bin/.   $out/bin/
      cp -r $src/lib/.   $out/lib/
      cp -r $src/state/. $out/state/

      substituteInPlace $out/lib/settings.sh $out/state/* \
        --replace-quiet '@MY_BT_DEV_01@' '${MY_BT_DEV_OVER_THE_EARS}' \
        --replace-quiet '@MY_BT_DEV_02@' '${MY_BT_DEV_IN_EAR_01}' \
        --replace-quiet '@MY_BT_DEV_03@' '${MY_BT_DEV_IN_EAR_02}'
    '';

    meta = with lib; {
      description = "Keksgesicht's audio setup script collection";
      platforms = platforms.all;
    };
  };
}
