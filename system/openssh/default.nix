{ config, lib, ...}:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable =
      if (config.networking.hostName != "cookiethinker")
      then lib.mkForce true
      else lib.mkForce false;
    openFirewall = false;
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 22;
      }
    ];
    settings = {
      LogLevel = "INFO";
      X11Forwarding = false;

      PasswordAuthentication = false;
      PermitEmptyPasswords = false;
      PermitRootLogin =
        if (config.networking.hostName == "cookieclicker"
         || config.networking.hostName == "cookiethinker")
        then lib.mkForce "no"
        else lib.mkForce "yes";
      PubkeyAuthentication = true;
      AuthorizedKeysFile = "%h/.config/ssh/authorized_keys /etc/ssh/authorized_keys.d/%u";

      LoginGraceTime = "42s";
      StrictModes = true;
      MaxAuthTries = 5;
      MaxSessions = 10;
    };
  };
}
