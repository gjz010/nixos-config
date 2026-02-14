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

    nixpkgs.overlays = [
      (final: super: {
        qt6Packages = super.qt6Packages.overrideScope (
          final: prev: {
            fcitx5-qt = prev.fcitx5-qt.overrideAttrs (
              old:
              let
                inherit (pkgs) fetchpatch2;
              in
              {
                patches = [
                  (fetchpatch2 {
                    url = "https://github.com/fcitx/fcitx5-qt/commit/46a07a85d191fd77a1efc39c8ed43d0cd87788d2.patch?full_index=1";
                    hash = "sha256-qv8Rj6YoFdMQLOB2R9LGgwCHKdhEji0Sg67W37jSIac=";
                  })
                  (fetchpatch2 {
                    url = "https://github.com/fcitx/fcitx5-qt/commit/6ac4fdd8e90ff9c25a5219e15e83740fa38c9c71.patch?full_index=1";
                    hash = "sha256-x0OdlIVmwVuq2TfBlgmfwaQszXLxwRFVf+gEU224uVA=";
                  })
                  (fetchpatch2 {
                    url = "https://github.com/fcitx/fcitx5-qt/commit/1d07f7e8d6a7ae8651eda658f87ab0c9df08bef4.patch?full_index=1";
                    hash = "sha256-22tKD7sbsTJcNqur9/Uf+XAvMvA7tzNQ9hUCMm+E+E0=";
                  })
                ];
              }
            );
          }
        );
      })
    ];
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        waylandFrontend = true;
        #plasma6Support = true;
        addons = with pkgs; [
          fcitx5-rime
          fcitx5-chinese-addons
          #fcitx5-configtool
          fcitx5-mozc
          #fcitx5-gtk
          #kdePackages.fcitx5-qt
        ];
      };
    };
  };
}
