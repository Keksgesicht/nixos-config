{ config, pkgs, lib, modulesPath
, system, username, home-dir, ... }:

{
  networking = {
    hostName = "live-cd-image";
    useDHCP = lib.mkForce true;
    firewall.enable = lib.mkForce false;
  };

  imports = [
    # nix build .'#'nixosConfigurations."live-cd".config.system.build.isoImage
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"

    ../../nix
    ../../nix/version-23-05.nix
    ../../system/base-pkgs.nix
    ../../system/shell-zsh.nix
  ]
  ++ lib.optionals (system == "x86_64-linux") [
    ../../hardware/x86_64/uefi.nix
  ]
  ;

  users.users."${username}" = {
    isNormalUser = true;
    description = "Cookie Installer User";
    shell = pkgs.zsh;
    uid = 1000;
    group = "${username}";
    home = "${home-dir}";
    homeMode = "700";
    createHome = true;
    extraGroups = [ "wheel" ];
    initialPassword = "qwerty123";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGVcKfTJylXQAdKWTmozXItrquCuODasumuWZ+7Mz9o nix@nixos-installer"
    ];
  };
  users.groups."${username}" = {
    gid = 1000;
  };
}
