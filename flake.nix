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
    };
    gjz010 = {
      url = "github:gjz010/nix-channel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
    };
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, flake-parts, nixos-wsl, sops-nix, gjz010, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { config, pkgs, system, ... }: {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.bashInteractive pkgs.sops pkgs.age pkgs.ssh-to-age ];
          EDITOR = ./scripts/editor.sh;
        };
      };
      flake = {
        nixosConfigurations = import ./machines inputs;
        nixosModules = import ./modules { inherit self inputs; };
      };
      systems = [ "x86_64-linux" "aarch64-linux" ];
    };

}
