{ config, pkgs, ... }:

let
  MY_IFLINK =
    if (config.networking.hostName == "cookieclicker") then
      "enp4s0"
    else if (config.networking.hostName == "cookiepi") then
      "enp0s31f6"
    else "eth0";
  MY_IPV6_ULU =
    if (config.networking.hostName == "cookieclicker") then
      "fd00:3581::192:168:178:150/64"
    else if (config.networking.hostName == "cookiepi") then
      "fd00:3581::192:168:178:25/64"
    else "";
  MY_IPV6_SUFFIX =
    if (config.networking.hostName == "cookieclicker") then
      "3581:150:0:1"
    else if (config.networking.hostName == "cookiepi") then
      "3581:25:0:1"
    else "";

  dispatchVars = ''
    export MY_IFLINK=${MY_IFLINK}
    export MY_IPV6_ULU=${MY_IPV6_ULU}
    export MY_IPV6_SUFFIX=${MY_IPV6_SUFFIX}
  '';
in
{
  networking.networkmanager = {
    dispatcherScripts = [ {
      type = "basic";
      source = pkgs.writers.writeBash "50-home-ipv6-ULU" (''
        export PATH=$PATH
      '' + dispatchVars
      + (builtins.readFile ../../files/linux-root/etc/NetworkManager/dispatcher.d/50-home-ipv6-ULU));
    } {
      type = "basic";
      source = pkgs.writers.writeBash "50-public-ipv6" (''
        export PATH=$PATH:"${pkgs.coreutils}/bin":"${pkgs.gawk}/bin":"${pkgs.procps}/bin"
      '' + dispatchVars
      + (builtins.readFile ../../files/linux-root/etc/NetworkManager/dispatcher.d/50-public-ipv6));
    } ];
  };

  systemd = {
    services = {
      "ipv6-prefix-update" = {
        enable = true;
        description = "Check whether IPv6 prefix has been updated and adjust static suffix to new IP";
        path = with pkgs; [ coreutils iproute2 gawk procps ];
        script = (builtins.readFile ../../files/linux-root/etc/NetworkManager/dispatcher.d/50-public-ipv6);
        scriptArgs = "${MY_IFLINK} prefix";
      };
    };
    timers = {
      "ipv6-prefix-update" = {
        enable = (config.networking.hostName != "cookiethinker");
        description = "regular IPv6 prefix update check";
        timerConfig = {
          OnStartupSec = "42min";
          OnUnitInactiveSec = "1000sec";
        };
        wantedBy = [ "timers.target" ];
      };
    };
  };
}
