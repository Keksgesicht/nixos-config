{ config, pkgs, ... }:

{
  networking.wireguard.interfaces =
    if (config.networking.hostName == "cookieclicker") then {
      "wg-server" = {
        privateKeyFile = "/etc/nixos/secrets/services/wireguard/private/wg-server";
        ips = [
          "192.168.176.1"
          "fd00:2307::1"
        ];
        listenPort = (import /etc/nixos/secrets/services/wireguard/server-port);
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
            presharedKeyFile = "/etc/nixos/secrets/services/wireguard/preshared/handy";
            allowedIPs = [
              "192.168.176.2"
              "fd00:2307::2"
            ];
          }
          {
            name = "laptop";
            publicKey = "dPEm0MGVEzRh+BYrROxXKGF9suOsQdQHldluvKryWQ4=";
            presharedKeyFile = "/etc/nixos/secrets/services/wireguard/preshared/laptop";
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
        privateKeyFile = "/etc/nixos/secrets/services/wireguard/private/wg-laptop";
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
            presharedKeyFile = "/etc/nixos/secrets/services/wireguard/preshared/server";
            endpoint = (builtins.readFile /etc/nixos/secrets/services/wireguard/server-endpoint);
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
