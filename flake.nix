{
  inputs = {
    # https://github.com/NixOS/nixpkgs
    # update nixpkgs every couple of days
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # https://nixos.wiki/wiki/Home_Manager
    # https://github.com/nix-community/home-manager
    # https://nix-community.github.io/home-manager/
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "master";
      rev = "6a35d1969e4626a0f8d285e60b6cfd331e2687a9";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # https://nixos.wiki/wiki/Impermanence
    # https://github.com/nix-community/impermanence
    impermanence = {
      type = "github";
      owner = "nix-community";
      repo = "impermanence";
      ref = "master";
      rev = "a33ef102a02ce77d3e39c25197664b7a636f9c30";
    };

    # https://nixos.wiki/wiki/Secure_Boot
    # https://github.com/nix-community/lanzaboote
    lanzaboote = {
      type = "github";
      owner = "nix-community";
      repo = "lanzaboote";
      ref = "master";
      rev = "3881267e84cc966ded48601390e88fc13d960319";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
      #inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    # https://github.com/nixpak/nixpak
    nixpak = {
      type = "github";
      owner = "nixpak";
      repo = "nixpak";
      ref = "master";
      rev = "b0862a125da8fe5d179633d6cc7aed57d5316871";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # https://github.com/pjones/plasma-manager
    plasma-manager = {
      type = "github";
      owner = "pjones";
      repo = "plasma-manager";
      ref = "trunk";
      rev = "96a90a7f5ce6b29e01d7da83d082e870e4462174";

      inputs.home-manager.follows = "home-manager";
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
    nixpak,
    plasma-manager,
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

        secrets-dir = "/etc/nixos/secrets";
      };
    in
    {
      # nix build -L .#nixosConfigurations."live-cd".config.system.build.toplevel
      "live-cd" = nixpkgs-stable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = myArgs // {
          inherit inputs;
          inherit system;
        };
        modules = [
          ./machines/installer
          home-manager.nixosModules.home-manager
        ];
      };
      "live-cd-graphics" = nixpkgs-unstable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = myArgs // {
          inherit inputs;
          inherit system;
        };
        modules = [
          ./machines/installer
          ./machines/installer/graphics.nix
          home-manager.nixosModules.home-manager
        ];
      };

      # sudo nixos-rebuild --flake . test -L
      "cookieclicker" = nixpkgs-unstable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = myArgs // {
          inherit inputs;
          inherit system;
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
          inherit system;
        };
        modules = [
          ./machines/cookiethinker.nix
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          lanzaboote.nixosModules.lanzaboote
        ];
      };

      "cookiepi" = nixpkgs-stable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = myArgs // {
          inherit inputs;
          inherit system;
        };
        modules = [
          ./machines/cookiepi.nix
          impermanence.nixosModules.impermanence
          lanzaboote.nixosModules.lanzaboote
        ];
      };

    };
  };
}
