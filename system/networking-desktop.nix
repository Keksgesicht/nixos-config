# file: system/neworking.nix
# desc: connecting with LAN and internet (e.g., ip addr, firewall, services)
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    cacert.unbundled
    dig
    ethtool
    wakeonlan
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

    dispatcherScripts =
      if (config.networking.hostName == "cookieclicker") then
        [ {
          type = "basic";
          source = pkgs.writers.writeBash "50-home-ipv6-ULU" (''
            export PATH=$PATH
          '' + (builtins.readFile ../files/linux-root/etc/NetworkManager/dispatcher.d/50-home-ipv6-ULU));
        } {
          type = "basic";
          source = pkgs.writers.writeBash "50-no-ddns-vpn" (''
            export PATH=$PATH
          '' + (builtins.readFile ../files/linux-root/etc/NetworkManager/dispatcher.d/50-no-ddns-vpn));
        } {
          type = "basic";
          source = pkgs.writers.writeBash "50-public-ipv6" (''
            export PATH=$PATH:"${pkgs.coreutils}/bin":"${pkgs.gawk}/bin":"${pkgs.procps}/bin"
          '' + (builtins.readFile ../files/linux-root/etc/NetworkManager/dispatcher.d/50-public-ipv6));
        } ]
      else []
    ;
  };

  systemd = {
    services = {
      "NetworkManager-wait-online" =
        # https://askubuntu.com/questions/1018576/what-does-networkmanager-wait-online-service-do
        if (config.services.xserver.enable) then
          { enable = lib.mkForce false; }
        else {};
      "ipv6-prefix-update" = {
        enable = (config.networking.hostName == "cookieclicker");
        description = "Check whether IPv6 prefix has been updated and adjust static suffix to new IP";
        path = with pkgs; [ coreutils iproute2 gawk procps ];
        script = (builtins.readFile ../files/linux-root/etc/NetworkManager/dispatcher.d/50-public-ipv6);
        scriptArgs = "enp4s0 prefix";
      };
    };
    timers = {
      "ipv6-prefix-update" = {
        enable = (config.networking.hostName == "cookieclicker");
        description = "regular IPv6 prefix update check";
        timerConfig = {
          OnStartupSec = "42min";
          OnUnitInactiveSec = "1000sec";
        };
        wantedBy = [ "timers.target" ];
      };
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
    # TUDa ESA-Infrastruktur (sshuttle)
    "10.5.0.38" = [ "gitlab.esa.informatik.tu-darmstadt.de" ];
  };
}
