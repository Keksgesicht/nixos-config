# file: system/neworking.nix
# desc: connecting with LAN and internet (e.g., ip addr, firewall, services)

{ config, ...}:

{
  # Enable networking via NetworkManager
  networking.networkmanager.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # firewall
  networking.firewall = {
    enable = true;
    #allowedTCPPorts = [ ... ];
    #allowedUDPPorts = [ ... ];
  };
}
