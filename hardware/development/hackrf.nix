{ config, ... }:

{
  # use HackRF as desktop user
  hardware.hackrf.enable = true;
  users.users."keks".extraGroups = [ "plugdev" ]; # reboot needed?

  /*
   * prefer GQRX
   * nix-shell -p gqrx --run gqrx
   * PIPEWIRE_LATENCY=256/48000 nix-shell -p sdrpp --run sdrpp
   */
}
