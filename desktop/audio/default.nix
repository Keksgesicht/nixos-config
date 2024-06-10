{ pkgs, username, ... }:

let
  my-audio = pkgs.callPackage ../../packages/my-audio.nix {};
in
{
  imports = [
    ./pipewire/mic-loop.nix
    ./pipewire/noise-filter.nix
  ];

  users.users."${username}".packages = with pkgs; [
    patchage
    pavucontrol
    pulseaudio
    qpwgraph
    # noise/voice filter
    rnnoise-plugin
    # (re)connect virtual devices
    my-audio
  ];

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    configPackages = [
      (pkgs.callPackage ../../packages/config-pipewire.nix {})
    ];
    wireplumber = {
      enable = true;
      configPackages = [
        (pkgs.callPackage ../../packages/config-wireplumber.nix {})
      ];
    };
  };

  # enable bluetooth
  hardware.bluetooth = {
    enable = true;
    # https://wiki.archlinux.org/title/bluetooth#Default_adapter_power_state
    powerOnBoot = false;
  };

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
        "pipewire.service"
      ];
    };
    # trying to even start a additional screencast concurrently to OBS-Studio (dmabuf?) will crash xdg-desktop-portal.service
    # restarting pipewire and co or xdg-desktop-portal and co does not help
    # complete logout is required or raise the fd limit of pipewire:
    "pipewire" = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        LimitNOFILE = 65536; # raises soft and hard limit
      };
    };
    # start Ferdium after my-audio
    # Otherwise services like Discord might not be able to use audio
    "app-ferdium@autostart" = {
      overrideStrategy = "asDropin";
      after = [
        "pipewire.service"
        "pipewire-pulse.service"
        "wireplumber.service"
        "my-audio.service"
      ];
    };
  };
}
