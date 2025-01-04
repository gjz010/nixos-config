flake@{ inputs, self, ... }:
{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  # See https://nix-community.github.io/home-manager/
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs;
}
