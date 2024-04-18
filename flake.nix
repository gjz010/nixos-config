{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs?rev=4107024ef4d9f637b568296f40a2ba0f62b13437";
    #nixpkgs.url = "path:/home/gjz010/playground/nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    gjz010.url = "github:gjz010/nix-channel";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, gjz010, sops-nix, ... }:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      nixosConfigurations = {
        "nixos-desktop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [ gjz010.overlays.default ];
              nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
                "TencentMeeting_0300000000_3.15.0.402_x86_64_default.publish.deb"
                "TencentMeeting_0300000000_3.19.0.401_x86_64_default.publish.deb"
                "steam"
                "steam-original"
                "steam-run"
              ];
            }
            ./configuration.nix
            #          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.gjz010 = import ./home.nix;
            }
            sops-nix.nixosModules.sops
            {
              nix.registry.nixpkgs.flake = nixpkgs;
              nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
              system.configurationRevision = self.rev or self.dirtyRev or "dirty";
            }
#            "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
          ];
        };
      };
    };
}

