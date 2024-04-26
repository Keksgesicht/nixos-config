{ config, pkgs, ... }:

let
  secrets-pkg = (pkgs.callPackage ../../../packages/my-secrets.nix {});
  nmsc-path = "linux-root/etc/NetworkManager/system-connections";
  nmsc-data = "${secrets-pkg}/${nmsc-path}";
in
{
  environment.etc = {
    "flake-output/my-secrets" = {
      source = secrets-pkg;
    };

    # network connections on all systems
    "NetworkManager/system-connections/TU_Darmstadt.nmconnection" = {
      mode = "0600";
      source = pkgs.substituteAll {
        src      =  ../../../files + "/${nmsc-path}/TU_Darmstadt.nmconnection";
        username = (builtins.readFile "${nmsc-data}/TU_Darmstadt-username");
      };
    };

    # network connections on server/desktop
    "NetworkManager/system-connections/dmz.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      mode = "0600";
      source = pkgs.substituteAll {
        src     =   ../../../files + "/${nmsc-path}/dmz.nmconnection";
        macaddr = (builtins.readFile "${nmsc-data}/cookieclicker-dmz-macaddr");
      };
    };
    "NetworkManager/system-connections/home.nmconnection" = {
      enable = (config.networking.hostName == "cookieclicker");
      mode = "0600";
      source = pkgs.substituteAll {
        src       =  ../../../files + "/${nmsc-path}/home.nmconnection";
        dnsserver = (builtins.readFile "${nmsc-data}/cookieclicker-home-dnsserver");
        ipaddr    = (builtins.readFile "${nmsc-data}/cookieclicker-home-ipaddr");
        macaddr   = (builtins.readFile "${nmsc-data}/cookieclicker-home-macaddr");
      };
    };

    # network connections on laptop
    "NetworkManager/system-connections/eduroam.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src      =  ../../../files + "/${nmsc-path}/eduroam.nmconnection";
        username = (builtins.readFile "${nmsc-data}/wlan01-username");
      };
    };
    "NetworkManager/system-connections/nach_Hause_telefonieren.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src      =  ../../../files + "/${nmsc-path}/nach_Hause_telefonieren.nmconnection";
        hostname = (builtins.readFile "${nmsc-data}/vpn-nachHause-host");
        username = (builtins.readFile "${nmsc-data}/vpn-nachHause-user");
      };
    };
    "NetworkManager/system-connections/wlan00.nmconnection" = {
      enable = (config.networking.hostName == "cookiethinker");
      mode = "0600";
      source = pkgs.substituteAll {
        src  =  ../../../files + "/${nmsc-path}/wlan00.nmconnection";
        ssid = (builtins.readFile "${nmsc-data}/wlan00-ssid");
      };
    };
  };
}
