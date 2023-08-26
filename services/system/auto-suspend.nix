{ config, pkgs, ...}:

{
  powerManagement = {
    # fancontrol hangs when resuming from suspend
    # Nix already does this ...
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/services/hardware/fancontrol.nix
    /*
    resumeCommands = ''
      systemctl restart --no-block fancontrol.service
    '';
    */
  };

  services.autosuspend = {
    enable = true;
    settings = {
      enable = true;
      interval = 60;
      idle_time = 42 * 60;
    };
    # https://autosuspend.readthedocs.io/en/latest/available_checks.html
    checks = {
      # Keep the system active when GUI user is logged in
      LocalUsers = {
        enabled = true;
        class = "LogindSessionsIdle";
        types = "tty,x11,wayland";
        states = "active,online";
        classes = "user";
      };

      # Keep SSH session alive
      SSH = {
        class = "ActiveConnection";
        ports = "22";
      };
    };
  };
}
