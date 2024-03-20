{ pkgs, sloth, bindHomeDir, ... }:

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
        # Otherwise, nix commands will behave strangely.
        #("/nix/store")
        ("/nix/var/log/nix")
        ("/nix/var/nix")
        (sloth.concat' sloth.homeDir "/texmf")
      ];
      bind.rw = [
        (bindHomeDir name "/.zhistory")
        #(sloth.concat' sloth.homeDir "/git")
      ];
      #network = true;
    };
  };
}
