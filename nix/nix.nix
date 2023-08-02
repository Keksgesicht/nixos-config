# file: nix/nix.nix
# desc: basic settings for nix tools itself

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  # allow packages with closed source code or paid products

  # https://discord.com/channels/@me/998534079425286214/1135687806459584662
  # make system useable during (re)build
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
  nix.daemonIOSchedPriority = 7;

  # https://discord.com/channels/@me/998534079425286214/1135859766376267886
  # "könnte ordentlich festplattenspeicher sparen" ~Moritz
  # $AUTH nix-store --optimise
  nix.settings.auto-optimise-store = true;
}
