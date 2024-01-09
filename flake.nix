{
  inputs = rec {
    nixpkgs-stable.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # https://nixos.wiki/wiki/Home_Manager
    # https://nix-community.github.io/home-manager/
    home-manager = {
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

    # https://github.com/pjones/plasma-manager
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.home-manager.follows = "home-manager";
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
    home-manager,
    impermanence,
    lanzaboote,
    plasma-manager,
    tuxedo-nixos,
  }@inputs: {
    nixosConfigurations =
    let
      myArgs = rec {
        username = "keks";
        home-dir = "/home/${username}";

        ssd-name = "main";
        ssd-mnt  = "/mnt/${ssd-name}";
        hdd-name = "array";
        hdd-mnt  = "/mnt/${hdd-name}";
        nvm-name = "ram";
        nvm-mnt  = "/mnt/${nvm-name}";
        data-dir = "${hdd-mnt}/homeBraunJan";

        cookie-dir  = "/etc/unCookie";
        secrets-dir = "/etc/nixos/secrets";
      };
    in
    {
      # sudo nixos-rebuild test -L --impure --flake .
      "cookieclicker" = nixpkgs-unstable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = myArgs // {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = system;
            #config.allowUnfree = true;
          };
        };
        modules = [
          ./machines/cookieclicker.nix
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          lanzaboote.nixosModules.lanzaboote
        ];
      };

      "cookiethinker" = nixpkgs-unstable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = myArgs // {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = system;
            #config.allowUnfree = true;
          };
        };
        modules = [
          ./machines/cookiethinker.nix
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
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
