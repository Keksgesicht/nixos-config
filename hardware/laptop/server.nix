{ ... }:

{
  # prevent suspend when closing lid
  services.logind = {
    lidSwitch = "lock";
    lidSwitchDocked = "lock";
    lidSwitchExternalPower = "lock";
  };
}
