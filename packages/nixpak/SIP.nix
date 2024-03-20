{ config, pkgs, sloth, bindHomeDir, ... }:

let
  name = "SIP";
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
        QT_PLUGIN_PATH = [
          "${pkgs.kdePackages.qtwayland}/lib/qt-6/plugins"
          "${pkgs.kdePackages.breeze}/lib/qt-6/plugins"
          "${pkgs.kdePackages.breeze-icons}/lib/qt-6/plugins"
          "${pkgs.kdePackages.frameworkintegration}/lib/qt-6/plugins"
        ];
      };
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
