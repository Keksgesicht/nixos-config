{ pkgs, bindHomeDir, ... }:

let
  name = "ThunderBird";
in
{
  nixpak."${name}" = {
    wrapper.packages = [
      { package = pkgs.thunderbird; binName = "thunderbird"; }
    ];

    dbus.policies = {
      "org.freedesktop.Notifications" = "talk";
      "org.mozilla.thunderbird.*" = "own";
    };

    bubblewrap = {
      bind.ro = [
        [
          # mozilla.cfg
          ("${pkgs.thunderbird}/lib/thunderbird")
          ("/app/etc/thunderbird")
        ]
      ];
      bind.rw = [
        (bindHomeDir name "/.thunderbird")
      ];
      network = true;
    };
  };
}
