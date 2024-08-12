{ lib, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkTransposedPerSystemModule
    ;
in
mkTransposedPerSystemModule {
  name = "bundlers";
  option = mkOption {
    type = types.lazyAttrsOf types.raw;
    default = { };
    description = ''
      nix bundle
    '';
  };
  file = ./bundlers.nix;
}