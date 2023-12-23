{ config, ... }:

{
  imports = [
    #./amdgpu-rocm.nix
    #./hackrf.nix
  ];
}
