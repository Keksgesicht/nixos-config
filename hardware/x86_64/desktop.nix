{ ... }:

{
  imports = [
    ./uefi.nix
    ../security/secure-boot.nix
    ../security/tpm2.nix
  ];
}
