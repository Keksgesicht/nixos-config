# ~/.config/autostart/
# https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.configFile
systemConfig: username:
{ config, ... }:

let
  flatpak-dir = "/var/lib/flatpak/exports/share/applications";
  profile-dir = "/etc/profiles/per-user/${username}/share/applications";
  mkOOSS = config.lib.file.mkOutOfStoreSymlink;
in
{
  xdg.configFile = {
    "autostart/brave-browser.desktop" = {
      source = mkOOSS "${profile-dir}/brave-browser.desktop";
      enable = (systemConfig.networking.hostName == "cookieclicker");
    };
    "autostart/ferdium.desktop" = {
      source = mkOOSS "${profile-dir}/ferdium.desktop";
      enable = (systemConfig.networking.hostName == "cookieclicker");
    };
    "autostart/thunderbird.desktop" = {
      source = mkOOSS "${profile-dir}/thunderbird.desktop";
      enable = (systemConfig.networking.hostName == "cookieclicker");
    };
    "autostart/com.github.hluk.copyq.desktop" = {
      source = mkOOSS "${profile-dir}/com.github.hluk.copyq.desktop";
    };
    "autostart/com.nextcloud.desktopclient.nextcloud.desktop" = {
      source = mkOOSS "${profile-dir}/com.nextcloud.desktopclient.nextcloud.desktop";
    };
  };
}
