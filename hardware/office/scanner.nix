{ pkgs, username, ... }:

# https://nixos.wiki/wiki/Scanners
let
  epson-gt-x750-config = pkgs.writeTextFile {
    name = "epson-gt-x750.conf";
    destination = "/etc/sane.d/epson-gt-x750.conf";
    text = ''
      usb 0x04b8 0x0119
    '';
  };
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.allowUnfreePackages = [
    #"iscan-2.30.4-2"
    #"iscan-gt-f720-bundle-2.30.4"
  ];

  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.epkowa
      epson-gt-x750-config
    ];
  };

  users.users."${username}" = {
    packages = with pkgs; [
      simple-scan
      #kdePackages.skanlite
    ];
    extraGroups = [
      "scanner"
      "lp"
    ];
  };
}
