flake@{ inputs, self, ... }:
{ lib, pkgs, config, ... }:
{
  nixpkgs.overlays = [ inputs.gjz010.overlays.default ];
}
