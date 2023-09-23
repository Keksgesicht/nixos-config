{ config, pkgs, lib, ...}:

let
  gpg-cfg = config.programs.gnupg;
in
{
  environment.systemPackages = with pkgs; [
    pandoc
    pinentry."${gpg-cfg.agent.pinentryFlavor}"
    (ventoy.override {
      withQt5 = (config.services.xserver.enable);
    })
  ];

  # make signed commits
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "qt";
  };
}
