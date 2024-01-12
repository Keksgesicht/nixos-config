# https://github.com/thiagokokada/nix-cage
{ config, inputs, system, ...}:

{
  environment = {
    systemPackages = [ inputs.nix-cage.defaultPackage."${system}" ];
    etc = {
      "nix-cage/devel.json" = {
        text = ''
          {
            "mounts": {
              "rw": [
                ["~/.cache/nix-cage", "~/.cache", "d"],
                ["~/.local/share/nix-cage/home/.zhistory", "~/.zhistory", "f"]
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
  };
}
