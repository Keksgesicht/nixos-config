{ config, pkgs, sloth, bindHomeDir, ... }:

let
  name = "SIP";
in
{
  nixpak."${name}" = if (config.networking.hostName == "cookieclicker") then {
    wrapper = {
      packages = [
        { package = pkgs.jami; binName = "jami"; }
      ];
      audio = true;
    };

    dbus.policies = {
      "org.freedesktop.Notifications" = "talk";
      "org.freedesktop.PowerManagement.Inhibit" = "talk";
      "cx.ring.Ring" = "own";
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/jami")
        (bindHomeDir name "/.config/jami.net")
        (bindHomeDir name "/.local/share/jami")
      ];
      network = true;
    };
  } else null;
}
