{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs@{ self, nixpkgs, home-manager, flake-parts, ... }: 
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        nixosConfigurations = {
          "gjz010-nixos-wsl" = nixpkgs.lib.nixosSystem {
            modules = [
              {
                networking.hostName = "gjz010-nixos-wsl";
              }
              (import ./setNixPath.nix {inherit nixpkgs self;})
              ./homeManagerConfig.nix
              home-manager.nixosModules.home-manager
              
              # From nixos-generate-config
              ./configuration.nix

              # User with home-manager
              ./users/gjz010.nix
            ];
          };
        };
      };
      systems = [ "x86_64-linux" ];
    };

}