flake@{ inputs, self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (import ./fcitx5.nix flake)
    (import ./nixos_ozone_wl.nix flake)
    (import ./fonts.nix flake)
  ];
  options = {
    gjz010.options.preferredDesktop = {
      enable = lib.mkEnableOption "Enable all preferred desktop options.";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.gjz010.options.preferredDesktop.enable {
      gjz010.options = {
        setNixOSOzoneWL.enable = true;
      };
      gjz010.programs = {
        fcitx5.enable = true;
        fonts.enable = true;
      };
    })
  ];
}
