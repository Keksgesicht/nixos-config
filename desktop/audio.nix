{ config, pkgs, lib, ... }:

{
  users.users.keks.packages = with pkgs; [
    # noise/voice filter
    rnnoise-plugin
    # (re)connect virtual devices
    (callPackage ../packages/init-audio.nix {})
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
  hardware.bluetooth.enable = true;
  # not needed on KDE Plasma
  #services.blueman.enable = true;

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
  systemd.user.services = {
    "init-audio" = {
      description = "Custom Audio Setup (pipewire)";
      path = [
        pkgs.gawk
        pkgs.pipewire
        pkgs.pulseaudio
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
        ExecStart = "${pkgs.callPackage ../packages/init-audio.nix {}}/bin/init-audio.sh";
        Type = "oneshot";
        RemainAfterExit = "true";
      };
      wantedBy = [
        "xdg-desktop-autostart.target"
      ];
    };
    # start Ferdium after init-audio
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
    };
  };
}
