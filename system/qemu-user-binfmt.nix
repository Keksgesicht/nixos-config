# file: system/qemu-user-binfmt.nix
# desc: available architectures for hidden emulation

{ config, pkgs, ... }:

{
  # enable running programs for other architectures with Qemu
  boot.binfmt.emulatedSystems =
    if (config.nixpkgs.hostPlatform == "x86_64-linux") then
      [
        "aarch64-linux"
        "aarch64_be-linux"
        "armv6l-linux"
        "armv7l-linux"
        "riscv32-linux"
        "riscv64-linux"
      ]
    else if (config.nixpkgs.hostPlatform == "aarch64-linux") then
      [
        "i386-linux"
        "i486-linux"
        "i586-linux"
        "i686-linux"
        "riscv32-linux"
        "riscv64-linux"
        "x86_64-linux"
      ]
    else [];
}
