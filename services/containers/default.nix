{ config, pkgs, cookie-dir, ...}:

let
  update-days = (builtins.head (builtins.split " " config.system.autoUpgrade.dates));
  image-updater = (pkgs.callPackage ../../packages/containers/image-updater.nix {});
in
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
        ExecStart = "${image-updater}/bin/get-container-image-hash.sh";

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
        OnCalendar = "${update-days} 01:44:12";
        RandomizedDelaySec = "30min";
        Persistent = "true";
      };
    };
  };
}
