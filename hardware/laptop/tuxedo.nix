{ config, ... }:

{
  # https://nixos.wiki/wiki/TUXEDO_Devices
  # https://github.com/AaronErhardt/tuxedo-rs
  hardware.tuxedo-rs = {
    #enable = true;
    #tailor-gui.enable = true;
  };
  hardware.tuxedo-keyboard.enable = true;
  boot.kernelParams = [
    "tuxedo_keyboard.mode=0"
    "tuxedo_keyboard.brightness=64"
    "tuxedo_keyboard.color_left=0xff0a0a"
  ];
}
