{
  description = "gjz010 Channel Flakified";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  outputs = { self, nixpkgs, flake-utils, ... }: 
  let overlay = import ./overlay.nix; 
  in
  (flake-utils.lib.eachDefaultSystem (system:
    let
    pkgs = nixpkgs.legacyPackages.${system}.extend overlay;
    in
    rec {
      packages =  pkgs.gjz010.pkgs;
      bundlers = {
        toTarball = pkgs.gjz010.lib.tarballBundler;
      };
    }
  )) // {
    overlays.default = overlay;
  };
}
