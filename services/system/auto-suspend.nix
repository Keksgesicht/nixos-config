{ ... }:

{
  services.autosuspend = {
    enable = true;
    settings = {
      enable = true;
      interval = 60;
      idle_time = 23 * 60;
    };
    # https://autosuspend.readthedocs.io/en/latest/available_checks.html
    checks = {
      # Keep the system active when GUI user is logged in
      LocalUsers = {
        enabled = true;
        class = "LogindSessionsIdle";
        types = "tty,wayland";
        states = "active,online";
        classes = "user";
      };
    };
  };
}
