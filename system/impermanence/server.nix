{ username, home-dir, ssd-mnt, ... }:

{
  # https://nixos.wiki/wiki/Impermanence#Home_Managing
  # https://github.com/nix-community/impermanence
  environment.persistence = {
    "${ssd-mnt}" = {
      hideMounts = true;
      # do not even try using the home-manager impermanence module
      users."${username}" = {
        directories = [
          "nixos-config"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "f  ${ssd-mnt}${home-dir}/.zhistory 644 ${username} ${username} - -"
  ];
}
