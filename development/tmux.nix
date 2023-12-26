{ config, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      # allow mouse scrolling
      # https://superuser.com/questions/209437/how-do-i-scroll-in-tmux
      set -g mouse on

      # Sane scrolling
      # https://superuser.com/questions/209437/how-do-i-scroll-in-tmux
      set -g terminal-overrides 'xterm*:smcup@:rmcup@'
    '';
  };
}
