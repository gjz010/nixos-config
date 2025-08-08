flake@{ inputs, self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    gjz010.hardware.yubikey = {
      enable = lib.mkEnableOption "Enable hardware Yubikey support.";
    };
  };
  config = lib.mkIf config.gjz010.hardware.yubikey.enable {
    services.udev.packages = [
      pkgs.yubikey-personalization
      pkgs.libfido2
      pkgs.fuse
    ];
    programs.yubikey-touch-detector = {
      enable = true;
      verbose = true;
    };
    environment.systemPackages =
      with pkgs;
      (
        [
          yubikey-manager
          yubico-piv-tool
        ]
        ++ (lib.optionals config.gjz010.options.preferredDesktop.enable [
          yubioath-flutter
        ])
      );
  };
}
