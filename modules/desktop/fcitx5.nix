flake@{ inputs, self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    gjz010.programs.fcitx5 = {
      enable = lib.mkEnableOption "Enable preferred fcitx5 configuration.";
    };
  };
  config = lib.mkIf config.gjz010.programs.fcitx5.enable {
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        waylandFrontend = true;
        plasma6Support = true;
        addons = with pkgs; [
          fcitx5-rime
          fcitx5-chinese-addons
          fcitx5-configtool
          fcitx5-mozc
          fcitx5-gtk
          kdePackages.fcitx5-qt
        ];
      };
    };
  };
}
