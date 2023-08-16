# file: system/neworking.nix
# desc: connecting with LAN and internet (e.g., ip addr, firewall, services)

{ config, pkgs, lib, ...}:

{
  environment.systemPackages = with pkgs; [
    cacert.unbundled
    dig
  ];
  environment.etc = {
    # symlinks certificate for eduroam
    "ssl/certs/T-TeleSec_GlobalRoot_Class_2.crt" = {
      source = "${pkgs.cacert.unbundled}/etc/ssl/certs/T-TeleSec_GlobalRoot_Class_2:1.crt";
    };

    # network connections on all systems
    "NetworkManager/system-connections/TU_Darmstadt.nmconnection" = {
      source = "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/TU_Darmstadt.nmconnection";
      mode = "0600";
    };

    # network connections on server/desktop
    "NetworkManager/system-connections/dmz.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      source = "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/dmz.nmconnection";
      mode = "0600";
    };
    "NetworkManager/system-connections/home.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      source = "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/home.nmconnection";
      mode = "0600";
    };

    # network connections on laptop
    "NetworkManager/system-connections/eduroam.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      source = "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/eduroam.nmconnection";
      mode = "0600";
    };
    "NetworkManager/system-connections/nach_Hause_telefonieren.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      source = "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/nach_Hause_telefonieren.nmconnection";
      mode = "0600";
    };
    "NetworkManager/system-connections/wlan00.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      source = "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/wlan00.nmconnection";
      mode = "0600";
    };
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

    dispatcherScripts = [ {
      type = "basic";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/dispatcher.d/50-home-ipv6-ULU;
        bash = "${pkgs.bash}";
      };
    } {
      type = "basic";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/dispatcher.d/50-no-ddns-vpn;
        bash = "${pkgs.bash}";
      };
    } {
      type = "basic";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/dispatcher.d/50-public-ipv6;
        bash = "${pkgs.bash}";
      };
    } ];
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
    # TUDa ESA-Infrastruktur (sshuttle)
    "10.5.0.38" = [ "gitlab.esa.informatik.tu-darmstadt.de" ];
  };
}
