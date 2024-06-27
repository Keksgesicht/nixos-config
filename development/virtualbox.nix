{ username, ... }:

{
  # https://nixos.wiki/wiki/VirtualBox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ username ];

  #nixpkgs.config.allowUnfree = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;
}
