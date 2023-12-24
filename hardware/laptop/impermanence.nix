{ config, pkgs, ... }:

{
  imports = [
    ../impermanence.nix
  ];

  environment.persistence = {
    # /root -> /mnt/main/home/root
    "/mnt/main/home" = {
      hideMounts = true;
      directories = [
      ];
      files = [
        "/root/.zhistory"
      ];
    };
  };
}
