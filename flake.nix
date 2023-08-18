{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      "nixos-desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
#          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
          }
          {
            nix.registry.nixpkgs.flake = nixpkgs;
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            system.configurationRevision = self.rev or "dirty";
          }
        ];
      };
    };
  };
}
