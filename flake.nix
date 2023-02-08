{
  description = "gjz010 Channel Flakified";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }: 
  let overlay = import ./overlay.nix; 
  in
  (flake-utils.lib.eachDefaultSystem (system:
    let
    pkgs = nixpkgs.legacyPackages.${system}.extend overlay;
    in
    rec {
      packages = flake-utils.lib.flattenTree {
        icalinguapp = pkgs.icalinguapp;
      };
    }
  )) // {overlays.default = overlay;};
}
