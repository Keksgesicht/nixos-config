{
  inputs = rec {
    nixpkgs-23-05.url = "nixpkgs/nixos-23.05";
    nixpkgs-stable = nixpkgs-23-05;
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs = nixpkgs-stable;
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self, nixpkgs,
    nixpkgs-23-05,
    nixpkgs-stable,
    nixpkgs-unstable,
    home-manager,
    lanzaboote,
    tuxedo-nixos
  }@inputs: {
    nixosConfigurations = {
      # sudo nixos-rebuild test -L --impure --flake .
      "cookieclicker" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = system;
            #config.allowUnfree = true;
          };
        };
        modules = [
          ./machines/cookieclicker.nix
          home-manager.nixosModules.home-manager
        ];
      };
      "cookiethinker" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = system;
            #config.allowUnfree = true;
          };
        };
        modules = [
          ./machines/cookiethinker.nix
          home-manager.nixosModules.home-manager
          tuxedo-nixos.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
        ];
      };
      # nix build ."#nixosConfigurations".pihole."config.system.build.toplevel" --impure
      "pihole" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./machines/pihole.nix
        ];
      };
      # nix build ."#nixosConfigurations".pihole-sd-card."config.system.build.sdImage" --impure
      "pihole-sd-card" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./machines/pihole.nix
          (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
          ({ config, ... }: {
            sdImage.compressImage = false;
          })
        ];
      };
    };
  };
}
