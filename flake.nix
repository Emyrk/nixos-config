{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/nix-index-database
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-index-database }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        # System76 laptop
        system76 = lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware/hardware-configuration.sys76.nix
            ./nixos/configuration.nix
            nix-index-database.nixosModules.nix-index
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.steven = import ./home/steven.nix;
            }
          ];
        };
        # Terra desktop
        desktop-amd64 = lib.nixosSystem
          {
            inherit system;
            modules = [
              ./hardware/hardware-configuration.terra.nix
              ./nixos/configuration.nix
              ./nixos/amd.pkgs.nix
              nix-index-database.nixosModules.nix-index
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.steven = import ./home/steven.nix;
              }
            ];
          };
      };
    };
}
