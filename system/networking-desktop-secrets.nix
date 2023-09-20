{ config, pkgs, ...}:

{
  environment.etc = {
    # network connections on all systems
    "NetworkManager/system-connections/TU_Darmstadt.nmconnection" = {
      mode = "0600";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/system-connections/TU_Darmstadt.nmconnection;
        username = (builtins.readFile "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/TU_Darmstadt-username");
      };
    };

    # network connections on server/desktop
    "NetworkManager/system-connections/dmz.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      mode = "0600";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/system-connections/dmz.nmconnection;
        macaddr = (builtins.readFile "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/cookieclicker-mac-addr-02");
      };
    };
    "NetworkManager/system-connections/home.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      mode = "0600";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/system-connections/home.nmconnection;
        macaddr = (builtins.readFile "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/cookieclicker-mac-addr-01");
      };
    };

    # network connections on laptop
    "NetworkManager/system-connections/eduroam.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/system-connections/eduroam.nmconnection;
        username = (builtins.readFile "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/wlan01-username");
      };
    };
    "NetworkManager/system-connections/nach_Hause_telefonieren.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/system-connections/nach_Hause_telefonieren.nmconnection;
        hostname = (builtins.readFile "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/vpn-nachHause-host");
        username = (builtins.readFile "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/vpn-nachHause-user");
      };
    };
    "NetworkManager/system-connections/wlan00.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/NetworkManager/system-connections/wlan00.nmconnection;
        ssid = (builtins.readFile "/etc/nixos/secrets/linux-root/etc/NetworkManager/system-connections/wlan00-ssid");
      };
    };
  };
}
