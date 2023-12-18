{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
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
            ./hardware/hardware-configuration.system76.nix
            ./nixos/configuration.nix
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
