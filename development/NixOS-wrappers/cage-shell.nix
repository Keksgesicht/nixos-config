{ config, pkgs, ...}:

let
  nix-cage-commit = "b831a0197efe69ae552182318f553e651474ff96";
  nix-cage-sha256 = "0nmq0z12m07snb4zl1ik12bqi62pqf20l6khhjgpnwad11cwl93x";
  nix-cage = import (fetchTarball {
    url = "https://github.com/thiagokokada/nix-cage/archive/${nix-cage-commit}.tar.gz";
    sha256 = "${nix-cage-sha256}";
  }) {};
in
{
  environment = {
    systemPackages = [ nix-cage ];
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
