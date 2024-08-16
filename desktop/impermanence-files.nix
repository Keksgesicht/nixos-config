{ config, pkgs, lib, inputs, username, home-dir, ssd-mnt, ... }:

let
  machine-name =
    if (config.networking.hostName == "cookieclicker")
      then "tower"
    else if (config.networking.hostName == "cookiethinker")
      then "laptop"
    else "none";

  xdgState = "${home-dir}/.local/state";

  my-audio = (pkgs.callPackage ../packages/my-audio.nix {});
  secrets-pkg = (pkgs.callPackage ../packages/my-secrets.nix {});
  plasma-config = (pkgs.callPackage ../packages/config-plasma.nix {});

  my-functions = (import ../nix/my-functions.nix lib);
in
with my-functions;
{
  imports = [
    ../nix/secrets-pkg.nix
  ];

  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
  systemd.tmpfiles.rules =
  let
    mkSymHomeFiles = fileList: (forEach fileList (elem:
      "L+ ${home-dir}/${elem} - - - - ${ssd-mnt}${home-dir}/${elem}"
    ));
    myHomeFiles = [
      ".config/session/dolphin_dolphin_dolphin"
      ".local/state/dolphinstaterc"
    ];

    cpHomeFile = (t: f: [
      "C  ${t} - - - - ${f}"
      "Z  ${t} 0644 ${username} ${username} - -"
    ]);

    initPlasmaFiles = mname: flatList (forEach (listFilesRec plasma-config) (e:
      let
        eFile = lib.removePrefix "${plasma-config}/" e;
        tFile = lib.removeSuffix ".machine-${mname}" "${home-dir}/${eFile}";
      in
      cpHomeFile tFile e
    ));
    initSecretFiles = flatList (forEach (listFilesRec "${secrets-pkg}/linux-root/home") (e:
      let
        eFile = lib.removePrefix "${secrets-pkg}/linux-root/home/" e;
        tFile = "${home-dir}/${eFile}";
      in
      cpHomeFile tFile e
    ));
    initWireplumberState = flatList (forEach (listFilesRec "${my-audio}/state") (e:
      let
        eFile = lib.removePrefix "${my-audio}/state/" e;
        tFile = "${xdgState}/wireplumber/${eFile}";
      in
      cpHomeFile tFile e
    ));
  in
  [
    "L+ ${home-dir}/.face                     - - - - ${inputs.self}/files/face.png"
    "L+ ${home-dir}/.face.icon                - - - - .face"
    "f+ ${home-dir}/.sudo_as_admin_successful - - - - -"
    "L+ ${home-dir}/.xscreensaver             - - - - .config/xscreensaver/config"
    "L+ ${home-dir}/.zhistory                 - - - - ${ssd-mnt}${home-dir}/.zhistory"
    "f+ ${home-dir}/.zshrc                    - - - - -"
  ] ++ [
    "d  ${home-dir}/.config/session - ${username} ${username} - -"
    "d  ${xdgState}              0700 ${username} ${username} - -"
    "d  ${xdgState}/wireplumber     - ${username} ${username} - -"
  ]
  ++ mkSymHomeFiles myHomeFiles
  ++ initPlasmaFiles (machine-name)
  ++ initSecretFiles
  ++ initWireplumberState
  ++ (cpHomeFile "${home-dir}/Downloads/.directory" ../files/dolphin.directory)
  ;
}
