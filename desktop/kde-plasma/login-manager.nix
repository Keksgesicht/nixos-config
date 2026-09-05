{ self, config, pkgs, ssd-mnt, home-dir, username, ... }:

let
  name = "plasmalogin";
  loginHome = "/var/lib/${name}";

  dn = "/dev/null";
  sdUser = "/.config/systemd/user";
  icons-path = ".local/share/icons";

  plasma-config = pkgs.callPackage "${self}/packages/config-plasma.nix" {};
  login-config = (file: src-ext: ''
    C  ${loginHome}/${file} - - - - ${plasma-config}/${file}${src-ext}
    Z  ${loginHome}/.config - ${name} ${name} - -
    Z  ${loginHome}/${file} 0644 - - - -
  '');

  bind-opt = [ "bind" "ro" "nofail" "x-gvfs-hide" ];
  bind-opts = {
    fsType = "none";
    options = bind-opt;
  };
  data-opts = { depends = [ loginHome home-dir ]; };
  bind-data = (path: bind-opts // data-opts // {
    device = "${ssd-mnt}${home-dir}/${path}";
  });
in
{
  # Enable the KDE Plasma Desktop Environment (wayland by default).
  services.displayManager = {
    plasma-login-manager = {
      enable = true;
      settings = {
        Greeter = {
          PreselectedSession = "";
          PreselectedUser = config.users.users."${username}".description;
        };
      };
    };
    defaultSession = "plasma";
  };

  environment.etc = {
    # setup ~/.config for SDDM
    "tmpfiles.d/ZZ-${name}-00.conf".text = ''
      d  ${loginHome}/.config          0750 ${name} ${name} - -
      d  ${loginHome}/wallpapers       0755 ${name} ${name} - -
      L+ /var/lib/AccountsService/icons/${username} - - - - ${self}/files/face.png
    '';
    # disable bootup sound (laptop)
    "tmpfiles.d/ZZ-${name}-10-no-audio.conf".text = ''
      d  ${loginHome}/.config/systemd  0750 ${name} ${name} - -
      d  ${loginHome}${sdUser}         0750 ${name} ${name} - -
      L+ ${loginHome}${sdUser}/pipewire.service       - - - - ${dn}
      L+ ${loginHome}${sdUser}/pipewire.socket        - - - - ${dn}
      L+ ${loginHome}${sdUser}/pipewire-pulse.service - - - - ${dn}
      L+ ${loginHome}${sdUser}/pipewire-pulse.socket  - - - - ${dn}
      L+ ${loginHome}${sdUser}/wireplumber.service    - - - - ${dn}
    '';
    # same config for user session and login manager
    "tmpfiles.d/ZZ-${name}-99-user-config.conf".text = ""
      + (login-config ".config/kcminputrc" "")
      + (login-config ".config/kdeglobals" "")
      + (login-config ".config/kglobalshortcutsrc" "")
      + (login-config ".config/kwinoutputconfig.json" ".machine-tower")
      + (login-config ".config/kwinrc" "")
      + (login-config ".config/plasma-localerc" "")
      + (login-config ".config/plasmarc" "")
    ;
  };

  fileSystems = {
    "${loginHome}/${icons-path}" = bind-data icons-path;
    "${loginHome}/wallpapers/ls" = bind-data "background/landscape";
  };

  systemd.services = {
    "login-kscreen-refreshRate" = {
      after = [ "systemd-tmpfiles-setup.service" ];
      wantedBy = [ "systemd-tmpfiles-setup.service" ];
      before = [ "plasmalogin.service" ];
      path = with pkgs; [ jq moreutils ];
      script = ''
        file=${loginHome}/.config/kwinoutputconfig.json
        jq --indent 4 '.[0].data[0].mode.refreshRate = 59977' "$file" | sponge "$file"
        jq --indent 4 '.[0].data[1].mode.refreshRate = 30000' "$file" | sponge "$file"
      '';
    };
    "login-random-wallpaper" = {
      unitConfig.RequiresMountsFor = "${loginHome}/wallpapers/ls";
      wantedBy = [ "plasmalogin.service" ];
      before = [ "plasmalogin.service" ];
      path = [ pkgs.coreutils ];
      script = ''
        cfg_file="/etc/plasmalogin.conf.d/99-wallpaper.conf"
        src_dir="${ssd-mnt}${home-dir}/background/landscape"
        src=$(ls "$src_dir" | shuf | head -n 1)
        echo '[Greeter][Wallpaper][org.kde.image][General]' > $cfg_file
        echo 'FillMode=0' >> $cfg_file
        echo 'Image=file://${loginHome}/wallpapers/ls/'"$src" >> $cfg_file
      '';
    };
  };
}
