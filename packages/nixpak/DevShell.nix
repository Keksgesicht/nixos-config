{ sloth, appDir, ... }:
{ pkgs, ssd-mnt, home-dir, ... }:

let
  name = "DevShell";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        pkgs.git
        pkgs.nix
        pkgs.rsync
      ];
    };

    bubblewrap = {
      bind.ro = [
        ("/etc/nix/nix.conf")
        ("/nix/var/log/nix")
        ("/nix/var/nix")
        (sloth.concat' sloth.homeDir "/texmf")
      ];
      bind.rw = [
        [
          (sloth.mkdir (appDir name))
          ("${ssd-mnt}${home-dir}")
        ]
        #(sloth.concat' sloth.homeDir "/git")
      ];
      network = true;
    };
  };
}
