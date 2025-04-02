{
  lib,
  pkgs,
  config,
  specialArgs,
  ...
}:
{
  nixpkgs.pkgs = (
    (import specialArgs.inputs.nixpkgs {
      inherit (config.nixpkgs)
        config
        overlays
        localSystem
        crossSystem
        ;
    })
  )
  /*
    .applyPatches {
        name = "tuxedo-drivers-293017";
        src = specialArgs.inputs.nixpkgs;
        patches = [./tuxedo-drivers-293017.patch];
    })
  */
  ;
}
