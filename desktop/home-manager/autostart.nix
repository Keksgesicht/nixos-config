# ~/.config/autostart/
# https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.configFile
systemConfig: username:
{ config, pkgs, ... }:

let
  profile-dir = "/etc/profiles/per-user/${username}/share/applications";
  mkOOSS = config.lib.file.mkOutOfStoreSymlink;

  copyq = rec {
    pkg = systemConfig.nixpak.BilderAnguck.output.env;
    dname = "com.github.hluk.copyq.desktop";
    dpath = "${pkg}/share/applications/${dname}";
  };
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
    "autostart/${copyq.dname}" = {
      source = mkOOSS (pkgs.runCommand "${copyq.dname}" {} ''
        cp ${copyq.dpath} $out
        sed -i 's|--start-server show|--start-server|g' $out
      '');
    };
    "autostart/com.nextcloud.desktopclient.nextcloud.desktop" = {
      source = mkOOSS "${profile-dir}/com.nextcloud.desktopclient.nextcloud.desktop";
    };
  };
}
