{ config, pkgs, ...}:

{
  # enables ssh-agent
  # avoids retyping passwords everytime
  programs.ssh = {
    startAgent = true;
    askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
    extraConfig = (builtins.readFile ../files/linux-root/etc/ssh/ssh_config);
  };
  environment.sessionVariables = rec {
    GIT_ASKPASS = "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
  };
}
