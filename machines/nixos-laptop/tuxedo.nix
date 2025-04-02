{
  lib,
  pkgs,
  config,
  ...
}:
{
  hardware.tuxedo-keyboard.enable = lib.mkForce false;
  boot.kernelModules = [
    "tuxedo_keyboard"
    "tuxedo_compatibility_check"
    "tuxedo_io"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.tuxedo-drivers ];
}
