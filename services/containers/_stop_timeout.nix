lib: tsec:

{
  serviceConfig = {
    TimeoutStopSec = lib.mkForce tsec;
  };
}
