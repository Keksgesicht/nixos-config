{ sloth, bindHomeDir, ... }:
{ config, pkgs-stable, ... }:

let
  name = "SIP";
  pkgs = pkgs-stable {};
in
{
  nixpak = if (config.networking.hostName == "cookieclicker") then {
  "${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.jami; binName = "jami"; }
      ];
      variables = {
        QT_QPA_PLATFORM = "wayland";
      };
      qtKDEintegration = true;
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
  }; } else {};
}
