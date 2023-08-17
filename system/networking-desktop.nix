# file: system/neworking.nix
# desc: connecting with LAN and internet (e.g., ip addr, firewall, services)

{ config, pkgs, lib, ...}:

{
  environment.systemPackages = with pkgs; [
    cacert.unbundled
  ];
  environment.etc = {
    # symlinks certificate for eduroam
    "ssl/certs/T-TeleSec_GlobalRoot_Class_2.crt" = {
      source = "${pkgs.cacert.unbundled}/etc/ssl/certs/T-TeleSec_GlobalRoot_Class_2:1.crt";
    };

    # network connections on all systems
    "NetworkManager/system-connections/TU_Darmstadt.nmconnection" = {
      source = ../secrets/linux-root/etc/NetworkManager/system-connections/TU_Darmstadt.nmconnection;
    };

    # network connections on server/desktop
    "NetworkManager/system-connections/dmz.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      source = ../secrets/linux-root/etc/NetworkManager/system-connections/dmz.nmconnection;
    };
    "NetworkManager/system-connections/home.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      source = ../secrets/linux-root/etc/NetworkManager/system-connections/home.nmconnection;
    };
    "NetworkManager/system-connections/wg-server.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      source = ../secrets/linux-root/etc/NetworkManager/system-connections/wg-server.nmconnection;
    };

    # network connections on laptop
    "NetworkManager/system-connections/eduroam.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      source = ../secrets/linux-root/etc/NetworkManager/system-connections/eduroam.nmconnection;
    };
    "NetworkManager/system-connections/nach_Hause_telefonieren.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      source = ../secrets/linux-root/etc/NetworkManager/system-connections/nach_Hause_telefonieren.nmconnection;
    };
    "NetworkManager/system-connections/wlan00.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      source = ../secrets/linux-root/etc/NetworkManager/system-connections/wlan00.nmconnection;
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
    #allowedTCPPorts = [ ... ];
    #allowedUDPPorts = [ ... ];
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
