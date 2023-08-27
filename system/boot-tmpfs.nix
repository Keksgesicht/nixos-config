{ config, ... }:

{
  boot = {
    #devSize = "5%";
    #devShmSize = "50%";
    #runSize = "25%";
    tmp = {
      # whether to delete all files in /tmp during boot
      cleanOnBoot = true;
      # whether to mount a tmpfs on /tmp during boot
      useTmpfs = true;
      tmpfsSize = "50%";
    };
  };
}
