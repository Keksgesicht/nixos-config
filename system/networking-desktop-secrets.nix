{ config, ...}:

{
  environment.etc = {
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
}
