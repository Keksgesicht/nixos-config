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
  environment.etc = {
    "pipewire/pipewire.conf.d/50-null-devices.conf" = {
      source = ../files/etc/pipewire/pipewire.d/50-null-devices.conf;
    };
    "pipewire/pipewire.conf.d/60-virtual-sinks.conf" = {
      source = ../files/etc/pipewire/pipewire.d/60-virtual-sinks.conf;
    };
  };

  # (re)connect virtual devices
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
}
