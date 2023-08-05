{ config, ...}:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable =
      if (config.networking.hostName == "nixos-installer")
      || (config.networking.hostName == "cookieclicker")
      then
        true
      else
        false
    ;
    listenAddresses.ipv4.addr = "0.0.0.0";
    listenAddresses.ipv6.addr = null;
    settings.PermitRootLogin = "no";
    extraConfig = ''
      LoginGraceTime 42s
      StrictModes yes
      MaxAuthTries 5
      MaxSessions 10

      PubkeyAuthentication yes
      PermitEmptyPasswords no
    '';
  };
}
