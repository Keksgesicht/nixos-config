{
  inputs = rec {
    nixpkgs-stable.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # https://nixos.wiki/wiki/Home_Manager
    # https://nix-community.github.io/home-manager/index.html
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # https://nixos.wiki/wiki/Impermanence
    impermanence = {
      url = "github:nix-community/impermanence/master";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # https://nixos.wiki/wiki/Secure_Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # https://nixos.wiki/wiki/TUXEDO_Devices
    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs-stable,
    nixpkgs-unstable,
    home-manager-stable,
    home-manager-unstable,
    impermanence,
    lanzaboote,
    tuxedo-nixos,
  }@inputs: {
    nixosConfigurations = {

      # sudo nixos-rebuild test -L --impure --flake .
      "cookieclicker" = nixpkgs-unstable.lib.nixosSystem rec {
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
          home-manager-unstable.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          lanzaboote.nixosModules.lanzaboote
        ];
      };

      "cookiethinker" = nixpkgs-unstable.lib.nixosSystem rec {
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
          home-manager-unstable.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote
          tuxedo-nixos.nixosModules.default
        ];
      };

      # nix build ."#nixosConfigurations".pihole."config.system.build.toplevel" --impure
      "pihole" = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./machines/pihole.nix
        ];
      };
      # nix build ."#nixosConfigurations".pihole-sd-card."config.system.build.sdImage" --impure
      "pihole-sd-card" = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./machines/pihole.nix
          (nixpkgs-stable + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
          ({ config, ... }: {
            sdImage.compressImage = false;
          })
        ];
      };

    };
  };
}
