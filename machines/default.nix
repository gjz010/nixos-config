inputs@{ nixpkgs, self, ... }:
{
  "nixos-desktop" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };

    modules = (builtins.attrValues self.nixosModules) ++ [
      ./nixos-desktop
      (
        { lib, ... }:
        {
          networking.hostName = "nixos-desktop";
        }
      )
    ];
  };
  "gjz010-nixos-wsl" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./gjz010-nixos-wsl
      (
        { lib, ... }:
        {
          networking.hostName = "gjz010-nixos-wsl";
        }
      )
    ];
  };
  "nixos-laptop" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./nixos-laptop
      (
        { lib, ... }:
        {
          networking.hostName = "nixos-laptop";
        }
      )
    ];
  };
  "nixos-pi" = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./nixos-pi
      (
        { lib, ... }:
        {
          networking.hostName = "nixos-pi";
        }
      )
    ];
  };
  "gjz010-nixos-server" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./gjz010-nixos-server
      (
        { lib, ... }:
        {
          networking.hostName = "gjz010-nixos-server";
        }
      )
    ];
  };
  "gjz010-nixos-miniserver-fr" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./gjz010-nixos-miniserver-fr
      (
        { lib, ... }:
        {
          networking.hostName = "gjz010-nixos-miniserver-fr";
        }
      )
    ];
  };
  "gjz010-nixos-miniserver-cn" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./gjz010-nixos-miniserver-cn
      (
        { lib, ... }:
        {
          networking.hostName = "gjz010-nixos-miniserver-cn";
        }
      )
    ];
  };
  "gjz010-nixos-box" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./gjz010-nixos-box
      (
        { lib, ... }:
        {
          networking.hostName = "gjz010-nixos-box";
        }
      )
    ];
  };
  "gjz010-nixos-laptop-mechrevo" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = (builtins.attrValues self.nixosModules) ++ [
      ./gjz010-nixos-laptop-mechrevo
      (
        { lib, ... }:
        {
          networking.hostName = "gjz010-nixos-laptop-mechrevo";
        }
      )
    ];
  };
}
