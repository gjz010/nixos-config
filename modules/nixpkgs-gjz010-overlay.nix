flake@{ inputs, self, ... }:
{ lib, pkgs, config, ... }:
{
  nixpkgs.overlays = [ self.overlays.default ];
}
