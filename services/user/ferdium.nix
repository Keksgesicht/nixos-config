{ config, pkgs, ...}:

{
  systemd.user = {
    services = {
      # one snapshot a day
      "ferdium" = {
        description = "Ferdium (flatpak)";
        after = [
          "init-audio.service"
        ];
        serviceConfig = {
          ExecStartPre = "sleep 1s";
          ExecStart = "${pkgs.flatpak}/bin/flatpak run org.ferdium.Ferdium --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WaylandWindowDecorations --ozone-platform-hint=wayland";
          ExecStop  = "${pkgs.flatpak}/bin/flatpak kill org.ferdium.Ferdium";
        };
        wantedBy = [
          "xdg-desktop-autostart.target"
        ];
      };
    };
  };
}
