{ config, inputs, ... }:

let
  impermanence = inputs.impermanence;

  username = "keks";
  home-dir = "/home/${username}";
  ssd-mnt  = "/mnt/main";
  hdd-mnt  = "/mnt/array";
  data-dir = "${hdd-mnt}/homeBraunJan";

  bind-opts = {
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
  };
  data-opts = {
    depends = [
      "${hdd-mnt}"
      "${home-dir}"
    ];
  };
in
{
  fileSystems = {
    "${home-dir}" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nr_inodes=1048576"
        "size=2G"
        "uid=${username}"
        "gid=${username}"
        "mode=700"
        "nodev"
        "noexec"
        "nosuid"
      ];
    };

    "${home-dir}/Documents" = bind-opts // data-opts // {
      device = "${data-dir}/Documents";
    };
    "${home-dir}/Downloads" = bind-opts // data-opts // {
      device = "${data-dir}/Downloads";
    };
    "${home-dir}/Music" = bind-opts // data-opts // {
      device = "${data-dir}/Music";
    };
    "${home-dir}/Pictures" = bind-opts // data-opts // {
      device = "${data-dir}/Pictures";
    };

    "${home-dir}/devel" = bind-opts // data-opts // {
      device = "${data-dir}/Documents/development";
    };
    "${home-dir}/git" = bind-opts // data-opts // {
      device = "${data-dir}/Documents/development/git";
    };
    "${home-dir}/Module" = bind-opts // data-opts // {
      device = "${data-dir}/Documents/Studium/Module";
    };
    "${home-dir}/Games" = bind-opts // {
      depends = [
        "/mnt/ram"
        "${home-dir}"
      ];
      device = "/mnt/ram/Games";
    };
  };

  # do not even try using the home-manager impermanence module
  environment.persistence = {
    "${ssd-mnt}" = {
      hideMounts = true;
      directories = [
        "${home-dir}/.cache"
        "${home-dir}/.config"
        "${home-dir}/.icons"
        "${home-dir}/.local/bin"
        "${home-dir}/.local/share"
        "${home-dir}/.local/state/wireplumber"
        "${home-dir}/.secrets"
        "${home-dir}/.tpm2_pkcs11"
        "${home-dir}/.var/app"
        "${home-dir}/background"
        "${home-dir}/Desktop"
        "${home-dir}/Public"
        "${home-dir}/Templates"
        "${home-dir}/texmf"
        "${home-dir}/WinePrefixes"
      ];
      files = [
        "${home-dir}/.face"
        "${home-dir}/.gtkrc-2.0"
        "${home-dir}/.gtkrc-2.0-kde4"
        "${home-dir}/.xscreensaver"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "L+ ${home-dir}/.face.icon                - - - - .face"
    "f+ ${home-dir}/.sudo_as_admin_successful - - - - -"
    "f+ ${home-dir}/.zshrc                    - - - - -"
  ];
}
