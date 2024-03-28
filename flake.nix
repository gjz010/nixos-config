{
  description = "gjz010 Channel Flakified";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }: 
  let gjz010_overlay = import ./overlay.nix {gjz010Flake = self;}; 
  overlay = nixpkgs.lib.composeExtensions rust-overlay.overlays.default gjz010_overlay;
  in
  (flake-utils.lib.eachDefaultSystem (system:
    let
    pkgs = import nixpkgs { inherit system; overlays = [overlay]; };
    in
    rec {
      packages =  pkgs.gjz010.pkgs;
      bundlers = {
        toTarball = pkgs.gjz010.lib.tarballBundler;
      };
    }
  )) // {
    overlays.default = overlay;
    overlays.single = gjz010_overlay;
    templates.dream2nix-nodejs-rollup-typescript-bin = {
      path = ./templates/dream2nix-nodejs-rollup-typescript-bin;
      description = "Using dream2nix to package a binary built using rollup and Typescript.";
    };
    templates.nixos-with-flake = {
      path = ./templates/nixos-with-flake;
      description = "A NixOS configuration using Flake and home-manager.";
    };
  };
}
