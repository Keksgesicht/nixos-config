{ config, lib, ... }:

let
  cfgNetName = config.networking.hostName;
in
{
  networking.useDHCP = lib.mkForce false;
  networking.firewall.enable = false;

  systemd.network.enable = true;
  systemd.network.networks."10-hetzner-wan" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "ipv4";
    routes = [ { routeConfig.Gateway = "fe80::1"; } ];
    address =
      if (cfgNetName == "cookiemailer") then [
        "2a01:4f8:c2c:63c5::1/64"
      ] else [];
  };

  # allow IPv6 too
  services.openssh.listenAddresses = [
    { addr = "[::]"; port = 22; }
  ];
}
