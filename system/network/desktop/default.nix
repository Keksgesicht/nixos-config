{ config, pkgs, lib, ... }:

let
  my-functions = (import ../../../nix/my-functions.nix lib);

  allowedPortsShared = {
    allowedTCPPorts = [
          53 # DNS
    ];
    allowedUDPPorts = [
          53 # DNS
          67 # DHCP server
        5353 # mDNS by avahi
    ];
  };
  allowedPortsCCbase = {
    allowedTCPPorts = [
         53 # DNS (Pihole)
         80 # HTTP (swag / lancache)
        443 # HTTPS (swag)
    ];
    allowedUDPPorts = [
         53 # DNS (Pihole)
        443 # HTTP3 (swag)
       5353 # mDNS by avahi
    ];
    allowedTCPPortRanges = [
      { from = 22200; to = 22299; } # free choice
    ];
    allowedUDPPortRanges = [
      { from = 22200; to = 22299; } # free choice
    ];
  };
  allowedPortsCCextra = {
    allowedTCPPorts = [
         22 # OpenSSH
       2053 # DNS (unbound)
    ];
    allowedUDPPorts = [
       2053 # DNS (unbound)
    ];
  };

  allowedPortsSSH = {
    allowedTCPPorts = if config.services.openssh.enable
      then [ 22 ]
      else [];
  };

  allowedPortsKDEconnect = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  allowedPortsVPNuser = {
    allowedTCPPortRanges = [
      { from = 10000; to = 65535; } # nearly all user ports
    ];
    allowedUDPPortRanges = [
      { from = 10000; to = 65535; } # nearly all user ports
    ];
  };
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
  services.avahi = {
    enable = true;
    openFirewall = false;
  };

  # firewall
  networking.firewall = {
    enable = true;

    interfaces =
      if (config.networking.hostName == "cookieclicker") then {
        "enp4s0" = lib.mkMerge [
          allowedPortsCCbase
          allowedPortsCCextra
          allowedPortsKDEconnect
        ];
        "wg-server" = lib.mkMerge [
          allowedPortsCCbase
          allowedPortsCCextra
          allowedPortsKDEconnect
        ];
        "podman-server" = allowedPortsCCbase;
        "enp6s0" = allowedPortsShared;
        "wlp5s0" = allowedPortsShared;
        #"tap0" = allowedPortsVPNuser;
      }
      else if (config.networking.hostName == "cookiethinker") then {
        "enp2s0" = allowedPortsShared;
        "wlo1" = {
          allowedUDPPorts = [ 5353 ];
        } // allowedPortsSSH;
      }
      else {};
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
    "192.168.178.25"  = [ "cookiepi.local" ];
    "192.168.178.147" = [ "cookiethinker.local" ];

    # TUDa ESA-Infrastruktur (sshuttle)
    "10.5.0.38" = [ "gitlab.esa.informatik.tu-darmstadt.de" ];
  };
}
