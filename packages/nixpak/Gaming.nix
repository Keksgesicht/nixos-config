{ specialArgs, config, pkgs, sloth, bindHomeDir, ... }:

let
  name = "Gaming";
  name-dir = "${specialArgs.home-dir}/.var/app/${name}";

  gamingPC = (config.networking.hostName == "cookieclicker");
  bindGamingHome = (dir: [
    (sloth.mkdir (sloth.concat [
      sloth.homeDir "/.var/app/GamingHome" dir
    ]))
    (sloth.concat' sloth.homeDir dir)
  ]);

  gameTools = (pkgs: [
    pkgs.gamemode
    pkgs.gamescope
    pkgs.mangohud
  ]);
  steamPkg = (pkgs.steam.override {
    extraPkgs = gameTools;
  });
  lutrisPkg = (pkgs.lutris.override {
    extraPkgs = (pkgs: ((gameTools pkgs) ++ [
      pkgs.kdePackages.konsole # terminal emulator
      pkgs.kdePackages.qttools # qdbus
      pkgs.wine
      pkgs.wine64
    ]));
  });
in
with specialArgs;
{
  nixpak = if gamingPC then {
  "${name}" = {
    wrapper = {
      packages = [
        # Steam
        { package = steamPkg; binName = "steam"; appFile = [
          { dst = "com.valvesoftware.Steam"; }
        ]; }
        pkgs.steamPackages.steamcmd

        # Heroic Games Launcher
        { package = pkgs.heroic; binName = "heroic"; appFile = [
          { src = "com.heroicgameslauncher.hgl"; args.extra = [
            "--enable-features=UseOzonePlatform" "--ozone-platform=wayland"
          ]; }
        ]; }

        # Minecraft
        { package = pkgs.prismlauncher; binName = "prismlauncher"; appFile = [
          { src = "org.prismlauncher.PrismLauncher"; }
        ]; }

        # Wine/Proton Manager
        { package = lutrisPkg; binName = "lutris"; appFile = [
          { src = "net.lutris.Lutris"; }
        ]; }
        /*
        { package = pkgs.bottles; binName = "bottles"; appFile = [
          { src = "com.usebottles.bottles"; }
        ]; }
        */

        # Proton update and configuration
        { package = pkgs.protonup-qt; binName = "protonup-qt"; }
        { package = pkgs.protontricks; binName = "protontricks"; }
      ];
      variables = {
        PULSE_SINK = "recording_out_sink";
        MANGOHUD_CONFIGFILE = "${home-dir}/.config/MangoHud/live.conf";
        XDG_DOCUMENTS_DIR = "${home-dir}/Documents/Gaming";
        XDG_DOWNLOAD_DIR = "${home-dir}/Download/Gaming";
        XDG_PICTURES_DIR = "${home-dir}/Pictures/Gaming";
        XDG_VIDEOS_DIR = "${home-dir}/Videos/Gaming/sandbox";
      };
      audio = true;
      time = true;
      qtKDEintegration = true;
    };

    flatpak.info = {
      # protontricks needs this for some reason
      Instance.flatpak-version = "1.14.5";
    };

    #dbus.args = [ "--log" ];
    dbus.policies = {
      "org.freedesktop.Notifications" = "talk";
      "org.freedesktop.PowerManagement.Inhibit" = "talk";
      "org.kde.StatusNotifierWatcher" = "talk"; # tray icon on KDE Plasma

      "com.steampowered.*" = "own";
      "net.lutris.Lutris" = "own";

      "com.feralinteractive.GameMode" = "talk";
    };

    bubblewrap = {
      bind.dev = [
        # XBox Controller Support
        # https://help.steampowered.com/en/faqs/view/0689-74B8-92AC-10F2#knownissues
        "/dev/bus/usb"
        "/dev/input"
        "/dev/uinput"
      ];
      bind.ro = [
        # host system information
        "/etc/lsb-release"
        "/etc/os-release"
        [
          (pkgs.writeText "${name}-machine-id" ''
            1337deadbeef42bad0815ccc4711da69
          '')
          "/etc/machine-id"
        ]
        [
          (pkgs.writeText "${name}-passwd" ''
            ${username}:x:1000:1000:Karl Keksgesicht:${home-dir}:${pkgs.zsh}/bin/zsh
            nfsnobody:x:65534:65534:Unmapped user:/:${pkgs.util-linux}/bin/nologin
          '')
          "/etc/passwd"
        ]
        [
          (pkgs.writeText "${name}-group" ''
            ${username}:x:1000:${username}
            nfsnobody:x:65534:
          '')
          "/etc/group"
        ]

        # hardware information
        # sensor reading (e.g. MangoHud)
        # controller support (e.g. XBox)
        "/run/dbus/system_bus_socket"
        "/sys/bus"
        "/sys/class"
        "/sys/dev"
        "/sys/devices"

        # 32-bit GPU Driver
        "/run/opengl-driver-32"

        (sloth.concat' sloth.xdgConfigHome "/MangoHud")
      ];
      bind.rw = [
        # Game data
        (sloth.mkdir (sloth.concat' sloth.homeDir "/Games"))
        (bindHomeDir name "/WinePrefixes")

        # xdg user dirs
        (sloth.mkdir (sloth.concat' sloth.xdgDocumentsDir "/Gaming"))
        (sloth.mkdir (sloth.concat' sloth.xdgDownloadDir "/Gaming"))
        (sloth.mkdir (sloth.concat' sloth.xdgPicturesDir "/Gaming"))
        (sloth.mkdir (sloth.concat' sloth.xdgVideosDir "/Gaming/sandbox"))

        # Steam, Heroic extra dirs
        (bindHomeDir name "/.pki")
        (bindGamingHome "/.config/cef_user_data")
        (bindGamingHome "/.config/unity3d")
        (bindGamingHome "/.local/share")

        # Steam
        (bindHomeDir name "/.steam")
        (bindHomeDir name "/.local/share/Steam")
        (bindHomeDir name "/.local/share/steamcmd")

        # Heroic Games Launcher
        (bindHomeDir name "/.config/heroic")
        (bindHomeDir name "/.config/legendary")

        # Minecraft
        (bindHomeDir name "/.local/share/PrismLauncher")

        # Lutris
        (bindHomeDir name "/.cache/lutris")
        (bindHomeDir name "/.config/lutris")
        (bindHomeDir name "/.local/share/lutris")

        # Bottles
        (bindHomeDir name "/.local/share/bottles")

        # ProtonUp GUI
        (bindHomeDir name "/.config/pupgui")
      ];
      network = true;
      sockets.x11 = true;
      #shareIpc = true;
    };
  }; } else {};

  hardware = if gamingPC then {
    # Enable udev rules for Steam hardware such as the Steam Controller
    steam-hardware.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = config.hardware.pulseaudio.enable;
  } else {};

  # optimise system performance on demand
  programs = if gamingPC then {
    gamemode.enable = true;
    #steam.remotePlay.openFirewall = true;
  } else {};

  nixpkgs.allowUnfreePackages = if gamingPC then [
    # steam
    pkgs.steam
    pkgs.steamPackages.steam
    # steamcmd
    pkgs.steam-run
    pkgs.steamPackages.steamcmd
  ] else [];

  # helps finding/showing the tray icon
  systemd.tmpfiles.rules = [
    "L+ ${home-dir}/.steam             - - - - ${name-dir}/.steam"
    "L+ ${home-dir}/.local/share/Steam - - - - ${name-dir}/.local/share/Steam"
  ];
}
