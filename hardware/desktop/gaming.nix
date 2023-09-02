{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    piper
  ];

  # configuring gaming mice
  services.ratbagd = {
    enable = true;
  };

  # Keyboard
  # https://github.com/anyc/skiller-ctl
}
