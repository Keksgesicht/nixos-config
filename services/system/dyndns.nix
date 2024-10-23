{ self, config, pkgs, myDomain, secrets-dir, ... }:

let
  ip-vars = import "${self}/system/network/IPv6/variables.nix" config;
  envVars = config.environment.sessionVariables;
  cfgNetName = config.networking.hostName;
in
{
  systemd = {
    services."hetzner-ddns" = {
      path = with pkgs; [
        bash curl gawk gnused iproute2 jq util-linux
      ];
      environment = ip-vars // {
        TTL =
          if (cfgNetName == "cookieclicker") then
            "300"
          else "1000";
        records =
          if (cfgNetName == "cookieclicker") then
            "150.host"
          else if (cfgNetName == "cookiepi") then
            "25.host"
          else "";
        domain = myDomain;
      };
      serviceConfig = {
        EnvironmentFile = "${secrets-dir}/keys/services/ddns/HETZNER_APIKEY";
        ExecStart = "${self}/files/scripts/hetzner-ddns.sh";
      };
    };
    timers."hetzner-ddns" = {
      timerConfig = {
        OnStartupSec = "123sec";
        OnUnitInactiveSec = "1234sec";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
