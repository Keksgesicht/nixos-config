{ config, pkgs, username, ... }:

{
  users.users."${username}".packages = with pkgs; [
    piper
  ];

  # configuring gaming mice
  services.ratbagd = {
    enable = true;
  };

  # Keyboard
  # https://github.com/anyc/skiller-ctl
}
