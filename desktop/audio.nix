# file: user/services.nix

{ config, pkgs, lib, ... }:

{
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    wireplumber.enable = true;
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  users.users.keks.packages = with pkgs; [
    rnnoise-plugin
  ];
  environment.etc = {
    "pipewire/pipewire.conf.d/50-null-devices.conf" = {
      source = ../files/linux-root/etc/pipewire/pipewire.d/50-null-devices.conf;
    };
    "pipewire/pipewire.conf.d/60-virtual-sinks.conf" = {
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/pipewire/pipewire.d/60-virtual-sinks.conf;
        pkgRnnoisePlugin = "${pkgs.rnnoise-plugin}";
      };
    };
  };

  # (re)connect virtual devices
  /*
  systemd.user.services = {
    "init-audio" = {
      description = "Custom Audio Setup (pipewire)";
      after = [
        "pipewire.service"
        "pipewire-pulse.service"
        "wireplumber.service"
      ];
      partOf = [
        "pipewire.service"
        "pipewire-pulse.service"
        "wireplumber.service"
      ];
      preStart = "sleep 3s";
      script = ;
    }
  }
   */
}
