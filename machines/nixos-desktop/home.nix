{ config, pkgs, ... }:
with pkgs;
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # optional for nix flakes support in home-manager 21.11, not required in home-manager unstable or 22.05
  #programs.direnv.nix-direnv.enableFlakes = true;
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gjz010";
  home.homeDirectory = "/home/gjz010";
  home.packages = [
    gjz010.pkgs.icalinguapp
    spectacle
    gjz010.pkgs.proxychains-wrapper
    x11vnc
    screen
    ark
    clinfo
    glxinfo
    gitFull
    gnupg
    gnumake
    cfssl
    openssl
    fluffychat
    vscodium
    element-desktop
    prismlauncher
    graalvm-ce
    ripgrep
    remmina
    libreoffice-qt
    wget
    kotatogram-desktop
    corectrl
    zotero
    gjz010.pkgs.wemeetapp
    (wrapOBS { plugins = with pkgs.obs-studio-plugins; [ obs-multi-rtmp ]; })
    renderdoc
    electron
    gcc
    httplib
    vlc
    firefox
    jq
    unar
    (yesplaymusic.overrideAttrs (final: prev: {
      src = fetchurl {
        url = "https://github.com/shih-liang/YesPlayMusicOSD/releases/download/v0.4.5/yesplaymusic_0.4.5_amd64.deb";
        sha256 = "04yab3122wi5vxv4i0ygas4pf50rvqz4s1khkz2hlnhj5j2p2k8h";
      };
      version = "0.4.5";
    }))
    zk
    fzf
    krita
    gimp
    sops
  ];
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.bash.enable = true;
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-chinese-addons fcitx5-configtool ];
  };
  systemd.user.services.x11vnc = {
    Unit = {
      Description = "X11VNC";
      After = [ "graphical-session.target" ];
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
    Service = {
      Type = "exec";
      ExecStart =
        let
          systemctl =
            "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} systemctl";
        in
        pkgs.writeScript "x11vnc-start" ''
          #! ${pkgs.runtimeShell} -el
          ${pkgs.x11vnc}/bin/x11vnc -usepw -display $DISPLAY -auth $XAUTHORITY -nevershared -forever
        '';
    };
  };
}
