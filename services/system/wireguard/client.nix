{ config, pkgs, lib, myDomain, secrets-pkg, secrets-dir, username, ... }:

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
  dns = [
    "192.168.176.2"
    "192.168.176.1"
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
      wgClientCfg = (endP: pKey: {
        autostart = false;
        privateKeyFile = "${wg-path-keys}/private/cookiethinker";
        address = [
          "192.168.176.102/24"
          "fd00:2307::10:2/64"
        ];
        inherit dns;
        mtu = 1280;
        peers = [ {
          endpoint = endP;
          publicKey = (wg-pubkey-path pKey);
          presharedKeyFile = "${wg-path-keys}/shared/cookiethinker";
          inherit allowedIPs;
        } ];
      });
    in
    {
      "wg-pi"      = (wgClientCfg  "25.host.${myDomain}:22243" "cookiepi");
      "wg-clicker" = (wgClientCfg "150.host.${myDomain}:22223" "cookieclicker");
    }
    else {}
  ;
}
