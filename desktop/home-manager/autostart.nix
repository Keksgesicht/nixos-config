systemConfig:
{ config, ... }:

let
  username = "keks";
  flatpak-dir = "/var/lib/flatpak/exports/share/applications";
  profile-dir = "/etc/profiles/per-user/${username}/share/applications";
  mkOOSS = config.lib.file.mkOutOfStoreSymlink;
in
{
  xdg.configFile = {
    "autostart/com.brave.Browser.desktop" = {
      source = mkOOSS "${flatpak-dir}/com.brave.Browser.desktop";
      enable = (systemConfig.networking.hostName == "cookieclicker");
    };
    "autostart/org.mozilla.firefox.desktop" = {
      source = mkOOSS "${flatpak-dir}/org.mozilla.firefox.desktop";
      enable = (systemConfig.networking.hostName  == "cookieclicker");
    };
    "autostart/org.mozilla.Thunderbird.desktop" = {
      source = mkOOSS "${flatpak-dir}/org.mozilla.Thunderbird.desktop";
      enable = (systemConfig.networking.hostName == "cookieclicker");
    };
    "autostart/com.github.hluk.copyq.desktop" = {
      source = mkOOSS "${flatpak-dir}/com.github.hluk.copyq.desktop";
    };
    "autostart/com.nextcloud.desktopclient.nextcloud.desktop" = {
      source = mkOOSS "${profile-dir}/com.nextcloud.desktopclient.nextcloud.desktop";
    };
  };
}
