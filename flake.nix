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
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, flake-parts, nixos-wsl, sops-nix, rust-overlay, nixos-anywhere, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flakemodules/bundlers.nix
      ];
      perSystem = { config, pkgs, system, ... }: {

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
          config = { };
        };

        formatter = pkgs.nixpkgs-fmt;
        packages = pkgs.gjz010.packages;
        bundlers = pkgs.gjz010.bundlers;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bashInteractive
            pkgs.sops
            pkgs.age
            pkgs.ssh-to-age
            nixos-anywhere.packages."${system}".nixos-anywhere
          ];
          EDITOR = ./scripts/editor.sh;
        };
      };
      flake = {
        flakeModules = {
          bundler = ./flakemodules/bundlers.nix;
        };
        nixosConfigurations = import ./machines inputs;
        nixosModules = import ./modules { inherit self inputs; };
        overlays.single = import ./channel/overlay.nix { gjz010Flake = self; };
        overlays.default = nixpkgs.lib.composeExtensions rust-overlay.overlays.default self.overlays.single;
        templates = import ./channel/templates;
      };
      systems = [ "x86_64-linux" "aarch64-linux" ];
    };

}
