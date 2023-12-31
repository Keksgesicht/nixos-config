{ config, pkgs, ... }:

{
  security.sudo = {
    enable = true;
    #package = pkgs.doas;
    execWheelOnly = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "${pkgs.systemd}/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl poweroff";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl suspend";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  environment.shellAliases = {
    poweroff  = "${pkgs.systemd}/bin/poweroff";
    reboot    = "${pkgs.systemd}/bin/reboot";
    systemctl = "${pkgs.systemd}/bin/systemctl";
  };
}
