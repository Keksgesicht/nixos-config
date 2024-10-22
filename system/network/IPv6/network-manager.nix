{ self, config, pkgs, ... }:

let
  ip-vars = (import ./variables.nix config);
  dispatchVars = with ip-vars; ''
    export MY_IFLINK=${MY_IFLINK}
    export MY_IPV6_ULU=${MY_IPV6_ULU}
    export MY_IPV6_SUFFIX=${MY_IPV6_SUFFIX}
  '';

  nm-script-path = "${self}/files/linux-root/etc/NetworkManager/dispatcher.d";
  pub6script =  (''
      PATH=$PATH:"${pkgs.coreutils}/bin":"${pkgs.gawk}/bin":"${pkgs.iproute2}/bin"
      PATH=$PATH:"${pkgs.procps}/bin":"${pkgs.util-linux}/bin"
      export PATH
    '' + dispatchVars
    + (builtins.readFile "${nm-script-path}/50-public-ipv6")
  );
in
{
  networking.networkmanager = {
    dispatcherScripts = [ {
      type = "basic";
      source = pkgs.writers.writeBash "50-home-ipv6-ULU" (''
        export PATH=$PATH
      '' + dispatchVars
      + (builtins.readFile "${nm-script-path}/50-home-ipv6-ULU"));
    } {
      type = "basic";
      source = pkgs.writers.writeBash "50-public-ipv6" pub6script;
    } ];
  };

  systemd = {
    services = {
      "ipv6-prefix-update" = {
        enable = (config.networking.hostName != "cookiethinker");
        description = "IPv6 prefix check and suffix updater";
        script = pub6script;
        scriptArgs = "${ip-vars.MY_IFLINK} prefix";
      };
    };
    timers = {
      "ipv6-prefix-update" = {
        enable = (config.networking.hostName != "cookiethinker");
        description = "regular IPv6 prefix update check";
        timerConfig = {
          OnStartupSec = "123sec";
          OnUnitInactiveSec = "1234sec";
        };
        wantedBy = [ "timers.target" ];
      };
    };
  };
}
