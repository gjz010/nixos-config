inputs@{ nixpkgs, self, ... }:
{
  "nixos-desktop" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };

    modules = (builtins.attrValues self.nixosModules) ++ [
      ./nixos-desktop
      ({ lib, ... }: {
        networking.hostName = "nixos-desktop";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      })
    ];
  };
  "gjz010-nixos-wsl" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./gjz010-nixos-wsl
      ({ lib, ... }: {
        networking.hostName = "gjz010-nixos-wsl";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      })
    ];
  };
  "nixos-laptop" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./nixos-laptop
      ({ lib, ... }: {
        networking.hostName = "nixos-laptop";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      })
    ];
  };
  "gjz010-nixos-server" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./gjz010-nixos-server
      ({ lib, ... }: {
        networking.hostName = "gjz010-nixos-server";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      })
    ];
  };
}
