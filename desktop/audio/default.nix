{ self, config, pkgs, username, ... }:

let
  hn = config.networking.hostName;
  inherit (config.KexOS.service."dummy".service) serviceConfig;
  pkg-dir = "${self}/packages";
  my-audio = config.KexOS.packages."my-audio";
  srvList = [
    "pipewire.service"
    "pipewire-pulse.service"
    "wireplumber.service"
  ];
in
{
  imports = [
    ./pipewire/mic-loop.nix
    ./pipewire/noise-filter.nix
    ./wireplumber/default.nix
    ../../packages/my-audio.nix
  ];

  users.users."${username}".packages = with pkgs; [
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
      (pkgs.callPackage "${pkg-dir}/config-pipewire.nix" {})
    ];
    wireplumber.enable = true;
  };

  systemd.user.services = {
    "my-audio" = {
      description = "Custom Audio Setup (pipewire)";
      path = with pkgs; [ gawk pipewire pulseaudio ripgrep ];
      after = srvList;
      partOf = srvList;
      wantedBy = srvList;
      serviceConfig = serviceConfig // {
        ExecStart = "${my-audio}/bin/audio-init.sh";
        Restart = if (hn == "cookieclicker")
                  then "always"
                  else "on-failure";
        Type = "exec";
        ProtectHome = "read-only";
        BindReadOnlyPaths = "/run/user/1000";
      };
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
      after = srvList ++ [ "my-audio.service" ];
    };
  };
}
