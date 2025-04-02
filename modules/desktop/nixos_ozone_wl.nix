flake@{ inputs, self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    gjz010.options.setNixOSOzoneWL = {
      enable = lib.mkEnableOption "exporting NIXOS_OZONE_WL";
    };
  };
  config = lib.mkIf config.gjz010.options.setNixOSOzoneWL.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
