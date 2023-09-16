# file: system/qemu-user-binfmt.nix
# desc: available architectures for hidden emulation

{ config, pkgs, ... }:

{
  # enable running programs for other architectures with Qemu
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "aarch64_be-linux"
    "armv6l-linux"
    "armv7l-linux"
    "riscv32-linux"
    "riscv64-linux"
  ];
}
