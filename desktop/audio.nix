{ config, pkgs, lib, ... }:

let
  my-audio = pkgs.callPackage ../packages/my-audio.nix {};
in
{
  users.users.keks.packages = with pkgs; [
    # noise/voice filter
    rnnoise-plugin
    # (re)connect virtual devices
    my-audio
  ];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    # force specific version
    package = pkgs.pipewire.overrideAttrs (finalAttrs: previousAttrs: {
      version = "0.3.78";
      src = previousAttrs.src.override {
        rev = finalAttrs.version;
        sha256 = "sha256-tiVuab8kugp9ZOKL/m8uZQps/pcrVihwB3rRf6SGuzc=";
      };
      buildInputs = previousAttrs.buildInputs ++ [ pkgs.ffado ];
    });

    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # enable bluetooth
  hardware.bluetooth = {
    enable = true;
    # https://wiki.archlinux.org/title/bluetooth#Default_adapter_power_state
    powerOnBoot = false;
  };

  environment.etc = {
    "pipewire/pipewire.conf.d/50-null-devices.conf" = {
      source = ../files/linux-root/etc/pipewire/pipewire.d/50-null-devices.conf;
    };
    "pipewire/pipewire.conf.d/60-virtual-sinks.conf" = {
      source = ../files/linux-root/etc/pipewire/pipewire.d/60-virtual-sinks.conf;
    };
    "pipewire/pipewire.conf.d/60-mic-loop.conf" = {
      source = ../files/linux-root/etc/pipewire/pipewire.d/60-mic-loop.conf;
      enable = (config.networking.hostName == "cookieclicker");
    };
    "pipewire/pipewire.conf.d/60-noise-filter.conf" = {
      source = pkgs.substituteAll {
        src = ../files/linux-root/etc/pipewire/pipewire.d/60-noise-filter.conf;
        pkgRnnoisePlugin = "${pkgs.rnnoise-plugin}";
      };
      enable = (config.networking.hostName == "cookieclicker");
    };
  };

  # (re)connect virtual devices
  systemd.user.services = {
    "my-audio" = {
      description = "Custom Audio Setup (pipewire)";
      path = [
        pkgs.gawk
        pkgs.pipewire
        pkgs.pulseaudio
        pkgs.ripgrep
      ];
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
      serviceConfig = {
        ExecStart = "${my-audio}/bin/audio-init.sh";
        Restart = "always";
        Type = "exec";
      };
      wantedBy = [
        "xdg-desktop-autostart.target"
      ];
    };
    # start Ferdium after my-audio
    # Otherwise services like Discord might not be able to use audio
    "flatpak-ferdium" = {
      description = "Ferdium (flatpak)";
      path = [
        pkgs.flatpak
      ];
      preStart = "sleep 1s";
      serviceConfig = {
        ExecStart = "${pkgs.flatpak}/bin/flatpak run org.ferdium.Ferdium --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WaylandWindowDecorations --ozone-platform-hint=wayland";
        ExecStop = "${pkgs.flatpak}/bin/flatpak kill org.ferdium.Ferdium";
      };
      environment = {
        TZ = "Europe/Berlin";
      };
    };
  };
}
