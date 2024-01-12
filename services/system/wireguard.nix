{ config, pkgs, secrets-dir, ... }:

let
  secrets-pkg = (pkgs.callPackage ../../packages/my-secrets.nix {});
  wg-path-data = "${secrets-pkg}/wireguard";
  wg-path-keys = "${secrets-dir}/keys/wireguard";
in
{
  environment.etc = {
    "flake-output/my-secrets" = {
      source = secrets-pkg;
    };
  };

  networking.wireguard.interfaces =
    if (config.networking.hostName == "cookieclicker") then {
      "wg-server" = {
        privateKeyFile = "${wg-path-keys}/private/wg-server";
        ips = [
          "192.168.176.1"
          "fd00:2307::1"
        ];
        listenPort = (import "${wg-path-data}/server-port");
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg-server -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.176.1/24 -o enp4s0 -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg-server -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fd00:2307::1/64 -o enp4s0 -j MASQUERADE
          ${pkgs.util-linux}/bin/logger -t wireguard "Tunnel WireGuard (wg-server) started"
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i wg-server -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.176.1/24 -o enp4s0 -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg-server -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fd00:2307::1/64 -o enp4s0 -j MASQUERADE
          ${pkgs.util-linux}/bin/logger -t wireguard "Tunnel WireGuard (wg-server) stopped"
        '';
        peers = [
          {
            name = "handy";
            publicKey = "ZfoguOSX/s4VQLjjWUnDdR6qkjNgl5xZPUEj8AFvHRs=";
            presharedKeyFile = "${wg-path-keys}/preshared/handy";
            allowedIPs = [
              "192.168.176.2"
              "fd00:2307::2"
            ];
          }
          {
            name = "laptop";
            publicKey = "dPEm0MGVEzRh+BYrROxXKGF9suOsQdQHldluvKryWQ4=";
            presharedKeyFile = "${secrets-dir}/keys/wireguard/preshared/laptop";
            allowedIPs = [
              "192.168.176.3"
              "fd00:2307::3"
            ];
          }
        ];
      };
    }
    else {}
  ;

  networking.wg-quick.interfaces =
    if (config.networking.hostName == "cookiethinker") then {
      "wg-laptop" = {
        autostart = false;
        privateKeyFile = "${wg-path-keys}/private/wg-laptop";
        address = [
          "192.168.176.3/24"
          "fd00:2307::3/64"
        ];
        dns = [
          "192.168.176.1"
        ];
        mtu = 1280;
        peers = [
          {
            publicKey = "hcFGcDc2l7fMsP1eOOiZY3df8ATGAmPQszyhQj+FAFE=";
            presharedKeyFile = "${wg-path-keys}/preshared/server";
            endpoint = (builtins.readFile "${wg-path-data}/server-endpoint");
            allowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
          }
        ];
      };
    }
    else {}
  ;
}
