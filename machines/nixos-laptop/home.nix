{ config, lib, pkgs, ... }:
let
  my-python-packages = pypi: with pypi; [ notebook numpy scipy matplotlib ];
  mypython = pkgs.python3.withPackages my-python-packages;
  mclauncher = pkgs.prismlauncher;
  gjz010 = pkgs.gjz010.pkgs;
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gjz010";
  home.homeDirectory = "/home/gjz010";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.packages = with pkgs;
    [
      pkgs.kdenlive
      pkgs.dmidecode
      pkgs.screen
      pkgs.gitFull
      pkgs.git-lfs
      pkgs.bind
      ark
      gdb
      ghc
      gimp
      gitFull
      imagemagick
      jq
      kate
      libreoffice-qt
      nodejs
      obs-studio
      pmutils
      mclauncher
      (gjz010.proxychains-wrapper)
      (gjz010.examples.completion-test)
      mypython
      ripgrep
      thunderbird
      vlc
      vscodium
      x11vnc
      zotero
      (coq_8_16.override { buildIde = true; })
      zip
      p7zip
      unar
      unzipNLS
      electron
      (gjz010.icalinguapp.override { electron = electron; })
      kotatogram-desktop
      element-desktop
      gmp
      opam
      usbimager
      nwjs-sdk
      ungoogled-chromium
      transmission-qt
      tor-browser-bundle-bin
      pdftk
      openal
      graalvm-ce
      cachix
      waypipe
      desktop-file-utils
      cloudflare-warp
      nix-index
      (gjz010.wemeetapp)
      texlive.combined.scheme-medium
      graphviz
      (gjz010.blivec-mpv)
      unrar
    ];
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.tmux.enable = true;
  programs.tmux.clock24 = true;
  programs.timidity.enable = true;
  #  programs.kdeconnect.enable = true;
}
