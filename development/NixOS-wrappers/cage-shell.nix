# https://github.com/thiagokokada/nix-cage
{ config, inputs, system, username, ...}:

{
  users.users."${username}".packages = [
    inputs.nix-cage.defaultPackage."${system}"
  ];

  environment.etc = {
    "nix-cage/devel.json" = {
      text = ''
        {
          "mounts": {
            "rw": [
              [ "~/.cache/nix-cage", "~/.cache", "d" ],
              [ "~/.local/share/nix-cage/home/.zhistory", "~/.zhistory", "f" ]
            ],
            "ro": [
              "~/texmf",
              "~/.zshrc"
            ]
          }
        }
      '';
    };
  };
}
