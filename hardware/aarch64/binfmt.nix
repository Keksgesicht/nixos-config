# file: system/qemu-user-binfmt.nix
# desc: available architectures for hidden emulation

{ config, pkgs, ... }:

{
  # enable running programs for other architectures with Qemu
  boot.binfmt.emulatedSystems = [
    "i386-linux"
    "i486-linux"
    "i586-linux"
    "i686-linux"
    "riscv32-linux"
    "riscv64-linux"
    "x86_64-linux"
  ];
}
