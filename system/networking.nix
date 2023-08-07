# file: system/neworking.nix
# desc: connecting with LAN and internet (e.g., ip addr, firewall, services)

{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    cacert.unbundled
  ];
  environment.etc = {
    # symlinks certificate for eduroam
    "ssl/certs/T-TeleSec_GlobalRoot_Class_2.crt" = {
      source = "${pkgs.cacert.unbundled}/etc/ssl/certs/T-TeleSec_GlobalRoot_Class_2:1.crt";
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
}
