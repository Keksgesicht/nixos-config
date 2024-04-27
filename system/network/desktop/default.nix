{ config, pkgs, lib, ... }:

let
  my-functions = (import ../../../nix/my-functions.nix lib);
in
with my-functions;
{
  imports = [
    ../.
    ../network-manager-ipv6.nix
  ];

  # symlinks for all certificates
  environment.etc =
  let
    cert-dir = "ssl/certs";
    cacert-dir = "${pkgs.cacert.unbundled}/etc/${cert-dir}";
    cert-set = builtins.listToAttrs
    ( map
      ( e:
        let
          eCert = lib.removePrefix "${cacert-dir}/" e;
          certName = builtins.head (builtins.split ":" eCert) + ".crt";
        in
        {
          name = "${cert-dir}/unbundled/${certName}";
          value = {
            source = e;
          };
        }
      )
      (listFilesRec cacert-dir)
    );
  in
  cert-set // {
    "ssl/certs/cacert-unbundled".source = cacert-dir;
  };

  # Enable networking via NetworkManager
  networking.networkmanager = {
    enable = true;

    # randomize IP and MAC addresses
    # https://fedoramagazine.org/randomize-mac-address-nm/
    # https://blogs.gnome.org/thaller/2016/08/26/mac-address-spoofing-in-networkmanager-1-4-0/
    wifi = {
      scanRandMacAddress = true;
      macAddress = "random";
    };
    ethernet.macAddress = "stable";
    connectionConfig = {
      "connection.stable-id" = "\${CONNECTION}/\${BOOT}";
    };

    dispatcherScripts = []
      ++ lib.optionals (config.networking.hostName == "cookieclicker") [ {
        type = "basic";
        source = pkgs.writers.writeBash "50-no-ddns-vpn" (''
          export PATH=$PATH
        '' + (builtins.readFile ../../../files/linux-root/etc/NetworkManager/dispatcher.d/50-no-ddns-vpn));
      } ];
  };

  systemd = {
    services = {
      "NetworkManager-wait-online" =
        # https://askubuntu.com/questions/1018576/what-does-networkmanager-wait-online-service-do
        if (config.services.xserver.enable) then
          { enable = lib.mkForce false; }
        else {};
    };
  };

  # enable mDNS responder
  services.avahi.enable = true;

  # firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts =
      if (config.networking.hostName == "cookieclicker") then
        [
          # 22 ssh OpenSSH (openssh.nix)
          53    # DNS (Pihole)
          80    # HTTP (swag / lancache)
          443   # HTTPS (swag)
          # 1714 to 1764 (kdeconnect)
          2053  # DNS (unbound)
        ]
      else [];
    allowedUDPPorts =
      if (config.networking.hostName == "cookieclicker") then
        [
          53    # DNS (Pihole)
          443   # HTTP3 (swag) TODO
          # 1714 to 1764 (kdeconnect)
          2053  # DNS (unbound)
          # 5353 mDNS by avahi
          22223 # Wireguard
        ]
      else [];
    allowedTCPPortRanges =
      if (config.networking.hostName == "cookieclicker") then
        [
          { from = 22200; to = 22299; }
        ]
      else [];
    allowedUDPPortRanges =
      if (config.networking.hostName == "cookieclicker") then
        [
          { from = 22200; to = 22299; }
        ]
      else [];
  };

  networking.hosts = {
    # multicast (from Fedora)
    "ff02::1" = [ "ip6-allnodes" ];
    "ff02::2" = [ "ip6-allrouters" ];

    # Pihole
    "192.168.178.23" = [ "rpi.pihole.local" ];
    "172.23.53.1" = [ "docker.pihole.local" ];
    # Router
    "192.168.178.1" = [ "fritz.box" ];

    # LAN devices
    "192.168.178.150" = [ "cookieclicker.local" ];
    "192.168.178.25" = [ "cookiepi.local" ];

    # TUDa ESA-Infrastruktur (sshuttle)
    "10.5.0.38" = [ "gitlab.esa.informatik.tu-darmstadt.de" ];
  };
}
