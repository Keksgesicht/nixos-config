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
      "x-gvfs-hide"
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
    "${home-dir}/Videos" = bind-opts // data-opts // {
      device = "${data-dir}/Videos";
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
      users."keks" = {
        directories = [
          ".cache"
          ".config"
          ".icons"
          ".local/bin"
          ".local/share"
          { directory = ".local/state/wireplumber"; user = username; group = username; }
          { directory = ".secrets"; mode = "0700"; }
          { directory = ".tpm2_pkcs11"; mode = "0700"; }
          ".var/app"
          "background"
          "texmf"
          "WinePrefixes"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "L+ ${home-dir}/.face.icon                - - - - .face"
    "f+ ${home-dir}/.sudo_as_admin_successful - - - - -"
    "f+ ${home-dir}/.zshrc                    - - - - -"

    # the persist file mount units do not wait for home-keks.mount
    "L+ ${home-dir}/.face           - - - - ${ssd-mnt}${home-dir}/.face"
    "L+ ${home-dir}/.gtkrc-2.0      - - - - ${ssd-mnt}${home-dir}/.gtkrc-2.0"
    "L+ ${home-dir}/.gtkrc-2.0-kde4 - - - - ${ssd-mnt}${home-dir}/.gtkrc-2.0-kde4"
    "L+ ${home-dir}/.xscreensaver   - - - - ${ssd-mnt}${home-dir}/.xscreensaver"
  ];
}
