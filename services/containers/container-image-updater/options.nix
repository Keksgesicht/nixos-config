{ config, pkgs, lib, ... }:

let
  inherit (lib) types;

  ciuOpts = { name, config, ... }: {
    options = {
      upstream.host = lib.mkOption {
        type = types.str;
        default = "docker.io";
      };
      upstream.name = lib.mkOption {
        type = types.str;
        default = "nixos/nix";
      };
      upstream.tag = lib.mkOption {
        type = types.str;
        default = "latest";
      };
      final.name = lib.mkOption {
        type = types.str;
        default = name;
      };
      final.tag = lib.mkOption {
        type = types.str;
        default = config.upstream.tag;
      };
    };
  };

  sd-name = (name: "container-image-updater@" + name);

  mkCIUservice = (config:
    {
      overrideStrategy = "asDropin";
      path = [
        pkgs.jq
        pkgs.nix-prefetch-docker
        pkgs.skopeo
      ];
      environment = {
        IMAGE_UPSTREAM_HOST = config.upstream.host;
        IMAGE_UPSTREAM_NAME = config.upstream.name;
        IMAGE_UPSTREAM_TAG  = config.upstream.tag;
        IMAGE_FINAL_NAME = "localhost/" + config.final.name;
        IMAGE_FINAL_TAG  = config.final.tag;
      };
    }
  );
  mkCIUtimer = {
    enable = true;
    overrideStrategy = "asDropin";
    wantedBy = [ "timers.target" ];
  };
in
with lib.attrsets;
{
  options.container-image-updater = lib.mkOption {
    default = {};
    type = types.attrsOf (types.submodule ciuOpts);
  };

  config.systemd = {
    services = (mapAttrs' (name: value: nameValuePair
      (sd-name name) (mkCIUservice value)
    ) config.container-image-updater);

    timers = (mapAttrs' (name: value: nameValuePair
      (sd-name name) (mkCIUtimer)
    ) config.container-image-updater);
  };
}
