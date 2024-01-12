{ config, pkgs, ... }:

let
  update-days = (builtins.head (builtins.split " " config.system.autoUpgrade.dates));
  image-updater = (pkgs.callPackage ../../packages/containers/image-updater.nix {});

  cookie-pkg = (pkgs.callPackage ../../packages/unCookie.nix {});
  cc-dir = "${cookie-pkg}/containers";
in
{
  environment.etc = {
    "flake-output/unCookie" = {
      source = cookie-pkg;
    };
  };

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
        ReadWritePaths = "${cc-dir}";
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
