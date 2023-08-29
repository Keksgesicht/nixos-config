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
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 22;
      }
    ];
    settings = {
      LogLevel = "INFO";
      X11Forwarding = true;

      PasswordAuthentication = false;
      PermitEmptyPasswords = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
      AuthorizedKeysFile = "%h/.config/ssh/authorized_keys /etc/ssh/authorized_keys.d/%u";

      LoginGraceTime = "42s";
      StrictModes = true;
      MaxAuthTries = 5;
      MaxSessions = 10;
    };
  };
}
