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
        desktop-amd64 = lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware/hardware-configuration.nix
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.steven = import ./home/steven.nix; # { inherit pkgs; };
            }
          ];
        };

        # hmConfig = {
        #   steven = home-manager.lib.homeManagerConfiguration {
        #     inherit system pkgs;
        #     username = "steven";
        #     homeDirectory = "/home/steven";
        #     configuration = {
        #       imports = {
        #         ./home/steven.nix
        #       };
        #     };
        #   }
        # };
      };
    };
}
