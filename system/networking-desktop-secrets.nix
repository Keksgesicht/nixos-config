{ config, pkgs, secrets-dir, ...}:

let
  nmsc-path = "linux-root/etc/NetworkManager/system-connections";
  nmsc-data = "${secrets-dir}/${nmsc-path}";
in
{
  environment.etc = {
    # network connections on all systems
    "NetworkManager/system-connections/TU_Darmstadt.nmconnection" = {
      mode = "0600";
      source = pkgs.substituteAll {
        src      =        ../files + "/${nmsc-path}/TU_Darmstadt.nmconnection";
        username = (builtins.readFile "${nmsc-data}/TU_Darmstadt-username");
      };
    };

    # network connections on server/desktop
    "NetworkManager/system-connections/dmz.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      mode = "0600";
      source = pkgs.substituteAll {
        src     =        ../files + "/${nmsc-path}//dmz.nmconnection";
        macaddr = (builtins.readFile "${nmsc-data}/cookieclicker-dmz-macaddr");
      };
    };
    "NetworkManager/system-connections/home.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker")
            || (config.networking.hostName == "pihole");
      mode = "0600";
      source =
        if (config.networking.hostName == "cookieclicker") then
          pkgs.substituteAll {
            src       =        ../files + "/${nmsc-path}//home.nmconnection";
            dnsserver = (builtins.readFile "${nmsc-data}/cookieclicker-home-dnsserver");
            ipaddr    = (builtins.readFile "${nmsc-data}/cookieclicker-home-ipaddr");
            macaddr   = (builtins.readFile "${nmsc-data}/cookieclicker-home-macaddr");
          }
        else if (config.networking.hostName == "pihole") then
          pkgs.substituteAll {
            src       =        ../files + "/${nmsc-path}//home.nmconnection";
            dnsserver = (builtins.readFile "${nmsc-data}/pihole-home-dnsserver");
            ipaddr    = (builtins.readFile "${nmsc-data}/pihole-home-ipaddr");
            macaddr   = "";
          }
        else        ../files + "/${nmsc-path}//home.nmconnection";
    };

    # network connections on laptop
    "NetworkManager/system-connections/eduroam.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src      =        ../files + "/${nmsc-path}//eduroam.nmconnection";
        username = (builtins.readFile "${nmsc-data}/wlan01-username");
      };
    };
    "NetworkManager/system-connections/nach_Hause_telefonieren.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src      =        ../files + "/${nmsc-path}//nach_Hause_telefonieren.nmconnection";
        hostname = (builtins.readFile "${nmsc-data}/vpn-nachHause-host");
        username = (builtins.readFile "${nmsc-data}/vpn-nachHause-user");
      };
    };
    "NetworkManager/system-connections/wlan00.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src  =        ../files + "/${nmsc-path}//wlan00.nmconnection";
        ssid = (builtins.readFile "${nmsc-data}/wlan00-ssid");
      };
    };
  };
}
