lib: tsec:

{
  serviceConfig = {
    RestartSec = "20sec";
    TimeoutStopSec = lib.mkForce tsec;
  };
}
