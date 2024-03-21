{ specialArgs, pkgs, sloth, appDir, ... }:

let
  name = "DevShell";
in
with specialArgs;
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
        [
          (sloth.concat' (appDir name) "/.zhistory")
          (sloth.concat' sloth.homeDir "/.zhistory")
        ]
        #(sloth.concat' sloth.homeDir "/git")
      ];
      #network = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d  ${home-dir}/.var/app/${name}           - ${username} ${username} - -"
    "f  ${home-dir}/.var/app/${name}/.zhistory - ${username} ${username} - -"
  ];
}
