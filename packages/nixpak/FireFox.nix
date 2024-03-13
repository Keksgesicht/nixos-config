{ pkgs, sloth, bindHomeDir, ... }:

let
  name = "FireFox";
in
{
  nixpak."${name}" = {
    wrapper.packages = [
      { package = pkgs.firefox; binName = "firefox"; }
    ];

    dbus.policies = {
      "org.mozilla.firefox.*" = "own";
    };

    bubblewrap = {
      bind.ro = [
        [
          # mozilla.cfg
          ("${pkgs.firefox}/lib/firefox")
          ("/app/etc/firefox")
        ]
      ];
      bind.rw = [
        (bindHomeDir name "/.mozilla")
        (sloth.mkdir (sloth.concat' sloth.homeDir "/Downloads/STG-backups"))
      ];
      network = true;
    };
  };
}
