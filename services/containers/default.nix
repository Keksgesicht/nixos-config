{ config, pkgs, cookie-dir, ...}:

{
  imports = [
    # https://search.nixos.org/options?channel=23.05&query=virtualisation.podman
    ../../system/container.nix
    # containers
    ./dyndns.nix
    ./lancache.nix
    ./nextcloud.nix
    ./pihole.nix
    ./proxy.nix
    ./unbound.nix
  ];

  systemd = {
    services."container-image-updater@" = {
      description = "Bump up container image version hashes [%i]";
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = "${pkgs.callPackage ../../packages/containers/image-updater.nix {}}/bin/get-container-image-hash.sh";

        PrivateTmp   = "yes";
        ProtectHome  = "yes";
        ProtectClock = "yes";
        ProtectProc  = "invisible";

        ReadOnlyPaths  = "/";
        ReadWritePaths = "${cookie-dir}/containers";
        #TemporaryFileSystem = "/etc:ro";
      };
    };
    timers."container-image-updater@" = {
      description = "Automatic container image version updater [%i]";
      timerConfig = {
        OnCalendar = "*-*-* 06:42:00";
        RandomizedDelaySec = "42min";
        Persistent = "true";
      };
    };
  };
}
