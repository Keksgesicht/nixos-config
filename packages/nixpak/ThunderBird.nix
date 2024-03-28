{ pkgs, lib, bindHomeDir, ... }:

let
  name = "ThunderBird";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.thunderbird; binName = "thunderbird"; }
      ];
      variables = {
        XDG_DATA_DIRS = lib.mkForce "";
      };
    };

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
        "/sys/bus/pci"
      ];
      bind.rw = [
        (bindHomeDir name "/.thunderbird")
      ];
      network = true;
    };
  };
}
