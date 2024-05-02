{ config, lib, system, ... }:

# https://nixos.wiki/wiki/Power_Management
# https://wiki.archlinux.org/title/CPU_frequency_scaling
let
  mobileSystem = (config.networking.hostName == "cookiethinker");
in
{
  powerManagement = {
    enable = true;
    # https://search.nixos.org/options?channel=unstable&show=powerManagement.cpuFreqGovernor
    # /sys/bus/cpu/devices/cpu0/cpufreq/scaling_governor
    cpuFreqGovernor = "ondemand";
  };

  boot.kernelParams = []
  ++ lib.optionals (system == "x86_64-linux") [
    "amd_pstate=guided"
  ];

  # https://nixos.wiki/wiki/Laptop
  # https://linrunner.de/tlp/settings/index.html
  services = {
    power-profiles-daemon.enable =
      if (mobileSystem) then (lib.mkForce false)
      else (lib.mkOptionDefault false);
    tlp = {
      enable = mobileSystem;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC   = "ondemand";
        CPU_ENERGY_PERF_POLICY_ON_AC = "ondemand";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;

        CPU_SCALING_GOVERNOR_ON_BAT   = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 33;

        # helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 42;
        STOP_CHARGE_THRESH_BAT0  = 88;
      };
    };
  };
}
