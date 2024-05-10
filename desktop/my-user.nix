{ config, pkgs, lib
, username, home-dir
, ssd-mnt, secrets-dir
, ... }:

let
  user-pw-path = "${secrets-dir}/keys/passwd/${username}";

  secrets-pkg = (pkgs.callPackage ../packages/my-secrets.nix {});
  keyPathClient = secrets-pkg + "/ssh/client";
in
{
  imports = [
    ../nix/secrets-pkg.nix
  ];

  users.users."${username}" = {
    isNormalUser = true;
    description = "Jan B.";
    shell = pkgs.zsh;
    uid = 1000;
    group = "${username}";
    home = "${home-dir}";
    homeMode = "700";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # Don't forget to create a password with `mkpasswd`.
    hashedPasswordFile = "${ssd-mnt}${user-pw-path}";
    # remote access
    openssh.authorizedKeys.keyFiles = []
      ++ lib.optionals (config.networking.hostName != "cookieclicker")
         [( keyPathClient + "/id_cookieclicker.pub" )]
      ++ lib.optionals (config.networking.hostName != "cookiethinker")
         [( keyPathClient + "/id_cookiethinker.pub" )]
    ;
  };

  users.groups."${username}" = {
    gid = 1000;
  };
}
