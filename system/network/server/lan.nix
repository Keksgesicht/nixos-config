{ config, pkgs, ... }:

let
  nmsc-path = "linux-root/etc/NetworkManager/system-connections";
in
{
  imports = [
    ../.
    ../network-manager-ipv6.nix
  ];

  networking.networkmanager.enable = true;

  systemd.services = {
    "NetworkManager-wait-online" = {
      environment.NM_ONLINE_TIMEOUT = "15";
    };
  };

  environment.etc = {
    "NetworkManager/system-connections/lan.nmconnection" = {
      enable = (config.networking.hostName == "cookiepi");
      mode = "0600";
      source = pkgs.substituteAll {
        src       =  ../../../files + "/${nmsc-path}/server-lan.nmconnection";
        dnsserver = "192.168.178.25;172.23.53.1;";
        ipaddr    = "192.168.178.25/24,192.168.178.1";
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # 22 ssh OpenSSH (openssh.nix)
      53    # DNS (Pihole)
      80    # HTTP (swag / lancache)
      443   # HTTPS (swag)
      2053  # DNS (unbound)
    ];
    allowedUDPPorts = [
      53    # DNS (Pihole)
      443   # HTTP3 (swag) TODO
      2053  # DNS (unbound)
    ];
    allowedTCPPortRanges = [
      { from = 22200; to = 22299; }
    ];
    allowedUDPPortRanges = [
      { from = 22200; to = 22299; }
    ];
  };

  networking.hosts = {
    # multicast (from Fedora)
    "ff02::1" = [ "ip6-allnodes" ];
    "ff02::2" = [ "ip6-allrouters" ];

    # Router
    "192.168.178.1" = [ "fritz.box" ];
  };
}
