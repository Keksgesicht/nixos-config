{ config, pkgs, ... }:

{
  imports = [
    ../.
    ../x86_64-uefi.nix
    ./filesystem.nix
  ];

  boot.kernel.sysctl = {
    # reboot on panic after x seconds
    "kernel.panic" = 60;

    # improve compilation
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_user_watches" = 1048576;

    # improve compatibility with Windows games through wine
    # Fedora 39: https://fedoraproject.org/wiki/Changes/IncreaseVmMaxMapCount
    # Brodie Robertson: https://www.youtube.com/watch?v=PsHRbfZhgXM
    "vm.max_map_count" = 2147483642;

    # enable router advertisement on LAN network adapter
    # combined with /etc/NetworkManager/dispatcher.d/50-public-ipv6
    # https://unix.stackexchange.com/questions/61641/how-can-i-disable-automatic-ipv6-neighbor-route-advertisement-on-a-router
    #"net.ipv6.conf.enp4s0.accept_ra" = 2;
  };
}
