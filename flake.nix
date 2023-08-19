{
  description = "NixOS configuration";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?rev=4107024ef4d9f637b568296f40a2ba0f62b13437";
    nixpkgs.url = "path:/home/gjz010/playground/nixpkgs";
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
