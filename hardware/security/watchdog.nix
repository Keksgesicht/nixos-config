{ ... }:

{
  # https://unix.stackexchange.com/questions/694464/how-to-make-systemd-to-stop-kicking-the-hardware-watchdog
  systemd.watchdog = {
    #device = "/dev/watchdog";
    runtimeTime = "2min";
    rebootTime  = "3min";
  };
}
