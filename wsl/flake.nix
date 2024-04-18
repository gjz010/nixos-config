{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-wsl = {
        url = "github:nix-community/NixOS-WSL";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
        url = "github:Mic92/sops-nix";
#        inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, flake-parts, nixos-wsl, sops-nix, ... }: 
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
              sops-nix.nixosModules.sops
              ./sops.nix
              # From nixos-generate-config
              ./configuration.nix
              (import ./nixos-wsl.nix {inherit nixos-wsl;})
              # User with home-manager
              ./users/gjz010.nix
            ];
          };
        };
      };
      systems = [ "x86_64-linux" ];
    };

}
