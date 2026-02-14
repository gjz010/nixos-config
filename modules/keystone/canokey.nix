flake@{ inputs, self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    gjz010.hardware.canokey = {
      enable = lib.mkEnableOption "Enable hardware Canokey support.";

    };
  };
  config = lib.mkIf config.gjz010.hardware.yubikey.enable (
    lib.mkMerge [
      {
        services.udev.packages = [
          pkgs.gjz010.pkgs.canokey-udev-rules
        ];
      }
    ]
  );
}
