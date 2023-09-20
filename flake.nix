{
  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-23.05";
      #url = "nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self, nixpkgs,
    home-manager,
    tuxedo-nixos
  }@inputs: {
    nixosConfigurations = {
      "cookieclicker" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration-cookieclicker.nix
          home-manager.nixosModules.home-manager
        ];
      };
      "cookiethinker" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration-cookiethinker.nix
          home-manager.nixosModules.home-manager
          tuxedo-nixos.nixosModules.default
        ];
      };
    };
  };
}
