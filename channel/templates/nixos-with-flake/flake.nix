{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        nixosConfigurations = {
          "nixos-desktop-alice" = nixpkgs.lib.nixosSystem {
            modules = [
              {
                networking.hostName = "nixos-desktop-alice";
              }
              (import ./setNixPath.nix { inherit nixpkgs self; })
              ./homeManagerConfig.nix
              home-manager.nixosModules.home-manager

              # From nixos-generate-config
              ./configuration.nix

              # User with home-manager
              ./users/alice.nix
            ];
          };
        };
      };
      systems = [ "x86_64-linux" ];
    };

}
