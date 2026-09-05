{ sloth, bindHomeDir, ... }:
{ config, pkgs, pkgs-latest, pkgs-stable, pkgs-fetch, lib
, nvm-mnt, home-dir, username, ... }:

let
  gamingPC = config.nixpak."${name}".enable;

  name = "Gaming";
  name-dir = "${home-dir}/.var/app/${name}";
  name-home = "${home-dir}/.var/home/${name}";

  disable64checks = (prev: pkg: prev."${pkg}".overrideAttrs {
    doCheck = !prev.stdenv.hostPlatform.isi686;
  } );
  overlays = lib.lists.forEach [
    # lutris -> buildFHS -> OpenLDAP (test checks)
    # https://github.com/NixOS/nixpkgs/issues/513245
    # https://github.com/NixOS/nixpkgs/issues/514113
    "openldap"
    # lutris -> buildFHS -> OpenBLAS (test checks) -> zblat3
    # https://discourse.nixos.org/t/openblas-i686-linux-hangs-in-checkphase-on-zblat3/78487
    "openblas"
  ] (e: (_: prev: {
    "${e}" = (disable64checks prev e);
  } ));

  pkgl = pkgs-latest { config.allowUnfree = true; inherit overlays; };
  pkgo = pkgs-stable { config.allowUnfree = true; inherit overlays; };
  pkgs-gs = pkgs-latest {};

  pkgMachineID = pkgs.writeText "${name}-machine-id" ''
    1337deadbeef42bad0815ccc4711da69
  '';
  pkgPasswd = pkgs.writeText "${name}-passwd" ''
    ${username}:x:1000:1000:Karl Keksgesicht:${home-dir}:${pkgs.zsh}/bin/zsh
    nfsnobody:x:65534:65534:Unmapped user:/:${pkgs.util-linux}/bin/nologin
  '';
  pkgGroup = pkgs.writeText "${name}-group" ''
    ${username}:x:1000:${username}
    nfsnobody:x:65534:
  '';

  bindGamingHome = (dir: [
    (sloth.mkdir (sloth.concat [
      sloth.homeDir "/.var/app/GamingHome" dir
    ]))
    (sloth.concat' sloth.homeDir dir)
  ]);

  # https://github.com/ValveSoftware/gamescope
  # --hdr-enabled --mangoapp
  gamescope-wrapper = (p: n: w:
    p.writers.writePython3Bin "gamescope-${n}" {
      libraries = [];
    } (''
      import os
      import sys
      gsBin = "${pkgs-gs.gamescope}"
      gsBin += "/bin/gamescope"
      gsArgs = [gsBin, "--borderless", "--adaptive-sync"]
      gsArgs += ["-W", "${w}", "-H", "1440", "-r", "120", "-o", "30"]

      # https://github.com/ValveSoftware/gamescope/issues/697
      orig_ldpl = os.environ.get("LD_PRELOAD", "")
      os.environ["LD_PRELOAD"] = ""
      mark = False
      for arg in sys.argv[1:]:
          gsArgs.append(arg)
          if not mark and arg == "--":
              set_ldpl = f"LD_PRELOAD={orig_ldpl}"
              gsArgs += ["env", set_ldpl]
              mark = True

      os.execvp(gsBin, gsArgs)
    '')
  );
  gameTools = (p: [
    p.vulkan-tools
    p.gamemode
    p.mangohud
    # gamescope aliase
    pkgs-gs.gamescope
    (gamescope-wrapper p "16" "2560")
    (gamescope-wrapper p "21" "3360")
    (gamescope-wrapper p "32" "4996") # 5120 - 2 * 62
  ]);
  steamPkg = (pkgl.steam.override {
    extraPkgs = (p: ((gameTools p) ++ [
      # XWayland of gamescope complains about this missing
      p.libkrb5
      p.keyutils
    ]));
  });
  lutrisPkg = (pkgo.lutris.override {
    extraPkgs = (p: ((gameTools p) ++ [
      p.kdePackages.konsole # terminal emulator
      p.kdePackages.qttools # qdbus
      p.python3 # UMU runtime script
      p.wine
      p.wine64
    ]));
  });
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        # Steam
        { package = steamPkg; binName = "steam"; appFile = [
          { dst = "com.valvesoftware.Steam"; }
        ]; }
        pkgl.steamcmd

        # Heroic Games Launcher
        { package = pkgl.heroic; binName = "heroic"; appFile = [
          { src = "com.heroicgameslauncher.hgl"; }
        ]; }

        # Minecraft
        { package = pkgo.prismlauncher; binName = "prismlauncher"; appFile = [
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
        { package = pkgl.protonup-qt; binName = "protonup-qt"; }
        { package = pkgl.protontricks; binName = "protontricks"; }
      ]
      # additional tools
      ++ gameTools pkgl
      ;
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

    gpu.enable = true;

    bubblewrap = {
      bind.dev = [
        # XBox Controller Support
        # https://help.steampowered.com/en/faqs/view/0689-74B8-92AC-10F2#knownissues
        "/dev/bus/usb"
        "/dev/input"
        "/dev/uinput"
        # new synchronisation method
        "/dev/ntsync"
      ];
      bind.ro = [
        # host system information
        "/etc/lsb-release"
        "/etc/os-release"

        [ "${pkgMachineID}" "/etc/machine-id" ]
        [ "${pkgPasswd}" "/etc/passwd" ]
        [ "${pkgGroup}" "/etc/group" ]

        # hardware information
        # sensor reading (e.g. MangoHud)
        # controller support (e.g. XBox)
        "/run/dbus/system_bus_socket"
        "/sys/bus"
        "/sys/class"
        "/sys/dev"
        "/sys/devices"

        # gamescope fix
        [ "${pkgs-gs.mesa}"      "/run/opengl-driver" ]
        [ "${pkgs-gs.mesa_i686}" "/run/opengl-driver-32" ]

        (sloth.concat' sloth.xdgConfigHome "/MangoHud")

        # X11 access (gamescope custom workaround)
        (sloth.env "XAUTHORITY")
      ];
      bind.rw = [
        # Game data
        (bindHomeDir name "/WinePrefixes")
        [
          "${nvm-mnt}/Games"
          (sloth.concat' sloth.homeDir "/Games")
        ]
        [
          (sloth.concat' "${name-dir}" "/WinePrefixes/Steam")
          (sloth.concat' sloth.homeDir "/Games/SteamLibrary/steamapps/compatdata")
        ]

        # xdg user dirs
        (sloth.mkdir (sloth.concat' sloth.xdgDocumentsDir "/Gaming"))
        (sloth.mkdir (sloth.concat' sloth.xdgDownloadDir "/Gaming"))
        (sloth.mkdir (sloth.concat' sloth.xdgPicturesDir "/Gaming"))
        (sloth.mkdir (sloth.concat' sloth.xdgVideosDir "/Gaming/sandbox"))

        # Steam, Heroic extra dirs
        (bindHomeDir name "/.pki")
        (bindGamingHome "/.cache/mesa_shader_cache")
        (bindGamingHome "/.cache/mesa_shader_cache_db")
        (bindGamingHome "/.cache/radv_builtin_shaders")
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

        # make X11 temp dir writeable inside sandbox
        # (gamescope custom workaround)
        "/tmp/.X11-unix"
      ];
      network = true;
      sockets.x11 = false; # gamescope custom workaround
      #shareIpc = true;
    };
  };

  hardware = if gamingPC then {
    graphics.enable32Bit = true;
  } else {};

  services = if gamingPC then {
    pulseaudio.support32Bit = config.services.pulseaudio.enable;
    # Enable udev rules for Steam hardware such as the Steam Controller
    # steam-hardware.enable = true;
    udev.packages = [
      pkgl.steam-unwrapped
    ];
  } else {};

  # optimise system performance on demand
  programs = if gamingPC then {
    gamemode.enable = true;
    #steam.remotePlay.openFirewall = true;
  } else {};

  # helps finding/showing the tray icon
  systemd.user.tmpfiles.users."${username}".rules = if gamingPC then [
    "L+ ${home-dir}/.steam             - - - - ${name-dir}/.steam"
    "L+ ${home-dir}/.local/share/Steam - - - - ${name-dir}/.local/share/Steam"

    "d  ${home-dir}/.var/home 0700 ${username} ${username} - -"
    "d  ${name-home}          0700 ${username} ${username} - -"
    "L  ${name-home}/.steampath  - - - - ${home-dir}/.steam/sdk32/steam"
    "L  ${name-home}/.steampid   - - - - ${home-dir}/.steam/steam.pid"
    "Z  ${name-home}/.steampath  - ${username} ${username} - -"
    "Z  ${name-home}/.steampid   - ${username} ${username} - -"
  ] else [];

  environment.etc = if gamingPC then {
    # make X11 temp dir writeable inside sandbox
    "tmpfiles.d/ZZ-gamescope-X11.conf".text = ''
      e  /tmp/.X11-unix 1777 ${username} ${username} - -
    '';
  } else {};

  boot.kernelModules = if gamingPC then [
    "ntsync"
  ] else [];
}
