{ config, pkgs, lib, secrets-pkg, secrets-dir, username, ... }:

let
  lo = lib.optionals;
  hn = config.networking.hostName;

  wg-path-data = "${secrets-pkg}/wireguard";
  wg-path-keys = "${secrets-dir}/keys/wireguard";

  wg-pubkey-path = (name:
    lib.removeSuffix "\n" (builtins.readFile "${wg-path-data}/public/${name}")
  );

  wg-cmd = (name:
    "${pkgs.wireguard-tools}/bin/wg show ${name}"
  );
  sc-cmd = (name: scss:
    "${pkgs.systemd}/bin/systemctl ${scss} wg-quick-${name}.service"
  );

  allowedIPs = [
    "0.0.0.0/0"
    "::/0"
  ];
in
{
  imports = [
    ../../../nix/secrets-pkg.nix
  ];

  programs.zsh.interactiveShellInit =
  let
    wg-up   = (sc-cmd "wg-$1" "start");
    wg-down = (sc-cmd "wg-$1" "stop");
    wg-show = (wg-cmd "wg-$1");
  in
  ''
    wg-tool() {
      case "$2" in
        up)   sudo ${wg-up}   ;;
        down) sudo ${wg-down} ;;
        show) sudo ${wg-show} ;;
      esac
    }
  '';

  security.sudo.extraRules =
  let
    options = [ "NOPASSWD" ];
    wg-sss = (name: [
      { inherit options; command = (sc-cmd name "start"); }
      { inherit options; command = (sc-cmd name "stop"); }
      { inherit options; command = (wg-cmd name); }
    ]);
  in
  [ {
    users = [ username ];
    commands = []
      ++ lo (hn == "cookiethinker") (wg-sss "wg-clicker")
      ++ lo (hn == "cookiethinker") (wg-sss "wg-pi")
      ;
  } ];

  networking.wg-quick.interfaces =
    if (config.networking.hostName == "cookiethinker") then
    let
      presharedKeyFile = "${wg-path-keys}/shared/cookiethinker";
      privateKeyFile = "${wg-path-keys}/private/cookiethinker";
      address = [
        "192.168.176.102/24"
        "fd00:2307::10:2/64"
      ];
      dns = [
        "192.168.176.2"
        "192.168.176.1"
      ];
    in
    {
      "wg-clicker" = {
        autostart = false;
        inherit privateKeyFile;
        inherit address;
        inherit dns;
        mtu = 1280;
        peers = [
          {
            endpoint = "150.host.keksgesicht.net:22223";
            publicKey = (wg-pubkey-path "cookieclicker");
            inherit presharedKeyFile;
            inherit allowedIPs;
          }
        ];
      };
      "wg-pi" = {
        autostart = false;
        inherit privateKeyFile;
        inherit address;
        inherit dns;
        mtu = 1280;
        peers = [
          {
            endpoint = "25.host.keksgesicht.net:22243";
            publicKey = (wg-pubkey-path "cookiepi");
            inherit presharedKeyFile;
            inherit allowedIPs;
          }
        ];
      };
    }
    else {}
  ;
}
