flake@{ inputs, self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    gjz010.programs.fonts = {
      enable = lib.mkEnableOption "My preferred fonts";
    };
  };
  config = lib.mkIf config.gjz010.programs.fonts.enable {
    fonts.packages = with pkgs; [
      wqy_zenhei
      wqy_microhei
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      sarasa-gothic
      jetbrains-mono
      dejavu_fonts
      nerd-fonts.symbols-only
    ];
  };
}
