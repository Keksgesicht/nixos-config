{ config, pkgs, lib, inputs, secrets-dir, ... }:

let
  hn = config.networking.hostName;

  secrets-pkg = (pkgs.callPackage "${inputs.self}/packages/my-secrets.nix" {});
  wg-path-data = "${secrets-pkg}/wireguard";
  wg-path-keys = "${secrets-dir}/keys/wireguard";

  wg-pubkey-path = (name:
    lib.removeSuffix "\n" (builtins.readFile "${wg-path-data}/public/${name}")
  );

  wg-nat = (ipv4: ipv6: port: ad:
    let
      iptbl4 = "${pkgs.iptables}/bin/iptables";
      iptbl6 = "${pkgs.iptables}/bin/ip6tables";
      logger = "${pkgs.util-linux}/bin/logger";
      nat-log =
        if (ad == "-A") then "started"
        else if (ad == "-D") then "stopped"
        else "unknown";
    in
    ''
      ${iptbl4} ${ad} FORWARD -i wg-server -j ACCEPT
      ${iptbl4} -t nat ${ad} POSTROUTING -s ${ipv4} -o ${port} -j MASQUERADE
      ${iptbl6} ${ad} FORWARD -i wg-server -j ACCEPT
      ${iptbl6} -t nat ${ad} POSTROUTING -s ${ipv6} -o ${port} -j MASQUERADE
      ${logger} -t wireguard "Tunnel WireGuard (wg-server) ${nat-log}"
    ''
  );

   wg-client-handy = (host: {
    name = "handy";
    publicKey = (wg-pubkey-path "handy-${host}");
    presharedKeyFile = "${wg-path-keys}/shared/handy-${host}";
    allowedIPs = [
      "192.168.176.101/32"
      "fd00:2307::10:1/128"
    ];
  });
  wg-client-laptop = {
    name = "cookiethinker";
    publicKey = (wg-pubkey-path "cookiethinker");
    presharedKeyFile = "${wg-path-keys}/shared/cookiethinker";
    allowedIPs = [
      "192.168.176.102/32"
      "fd00:2307::10:2/128"
    ];
  };
in
{
  imports = [
    ../../../nix/secrets-pkg.nix
  ];

  networking.wireguard.interfaces =
    if (hn == "cookieclicker") then
    let
      name = "cookieclicker";
      ipv4 = "192.168.176.1/24";
      ipv6 = "fd00:2307::1/64";
      port = "enp4s0";
    in
    {
      "wg-server" = {
        privateKeyFile = "${wg-path-keys}/private/${name}";
        ips = [ ipv4 ipv6 ];
        listenPort = 22223;
        postSetup = (wg-nat ipv4 ipv6 port "-A");
        postShutdown = (wg-nat ipv4 ipv6 port "-D");
        peers = [
          {
            name = "cookiepi";
            endpoint = "25.host.keksgesicht.net:22243";
            publicKey = (wg-pubkey-path "cookiepi");
            presharedKeyFile = "${wg-path-keys}/shared/${name}-cookiepi";
            allowedIPs = [
              "192.168.176.0/24"
              "fd00:2307::/64"
            ];
          }
          (wg-client-handy name)
          wg-client-laptop
        ];
      };
    }
    else if (hn == "cookiepi") then
    let
      name = "cookiepi";
      ipv4 = "192.168.176.2/24";
      ipv6 = "fd00:2307::2/64";
      port = "enp0s31f6";
    in
    {
      "wg-server" = {
        privateKeyFile = "${wg-path-keys}/private/${name}";
        ips = [ ipv4 ipv6 ];
        listenPort = 22243;
        postSetup = (wg-nat ipv4 ipv6 port "-A");
        postShutdown = (wg-nat ipv4 ipv6 port "-D");
        peers = [
          {
            name = "cookieclicker";
            #endpoint = "150.host.keksgesicht.net:22223";
            publicKey = (wg-pubkey-path "cookieclicker");
            presharedKeyFile = "${wg-path-keys}/shared/cookieclicker-${name}";
            allowedIPs = [
              "192.168.176.0/24"
              "fd00:2307::/64"
            ];
          }
          (wg-client-handy name)
          wg-client-laptop
        ];
      };
    }
    else {}
  ;
}
