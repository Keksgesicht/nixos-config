{ config, ... }:

{
  imports = [
    #./amdgpu-rocm.nix
    #./hackrf.nix
    ./htop.nix
    ./utils.nix
  ];
}
