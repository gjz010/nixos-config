{
  config,
  pkgs,
  specialArgs,
  ...
}:
with pkgs;
let
  electron = pkgs.gjz010.pkgs.electron_33-bin;
  symbols-nerd-font = (
    stdenv.mkDerivation {
      pname = "symbols-nerd-font";
      version = "2.2.0";
      src = fetchFromGitHub {
        owner = "ryanoasis";
        repo = "nerd-fonts";
        rev = "v3.2.1";
        hash = "sha256-lHnp4fPDZK4aPv6CZyBf03ylajGfxuqjhWzn7ubLlIU=";
        sparseCheckout = [
          "10-nerd-font-symbols.conf"
          "patched-fonts/NerdFontsSymbolsOnly"
        ];
      };
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        runHook preInstall

        fontconfigdir="$out/etc/fonts/conf.d"
        install -d "$fontconfigdir"
        install 10-nerd-font-symbols.conf "$fontconfigdir"

        fontdir="$out/share/fonts/truetype"
        install -d "$fontdir"
        install "patched-fonts/NerdFontsSymbolsOnly/complete/Symbols-2048-em Nerd Font Complete.ttf" "$fontdir"

        runHook postInstall
      '';
      enableParallelBuilding = true;
    }
  );
in
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
    (gjz010.pkgs.icalinguapp.override { inherit electron; })
    spectacle
    gjz010.pkgs.proxychains-wrapper
    x11vnc
    screen
    clinfo
    glxinfo
    gnupg
    gnumake
    cfssl
    openssl
    #fluffychat
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
    zotero_7
    gjz010.pkgs.wemeetapp
    (wrapOBS { plugins = with pkgs.obs-studio-plugins; [ obs-multi-rtmp ]; })
    renderdoc
    electron
    httplib
    vlc
    firefox
    jq
    unar
    #    (yesplaymusic.overrideAttrs (
    #      final: prev: {
    #        src = fetchurl {
    #          url = "https://github.com/shih-liang/YesPlayMusicOSD/releases/download/v0.4.5/yesplaymusic_0.4.5_amd64.deb";
    #          sha256 = "04yab3122wi5vxv4i0ygas4pf50rvqz4s1khkz2hlnhj5j2p2k8h";
    #        };
    #        version = "0.4.5";
    #      }
    #    ))
    zk
    fzf
    krita
    gimp
    sops
    retroarch
    retroarch-assets
    font-awesome
    pavucontrol
    slurp
    grim
    wl-clipboard
    wofi
    polybarFull
    sxhkd
    nerd-fonts.symbols-only
    i3lock-fancy
    xdo
    xdotool
    libnotify
    xournalpp
  ];
  programs.waybar.enable = true;
  fonts.fontconfig.enable = true;
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
  #i18n.inputMethod = {
  #  enabled = "fcitx5";
  #  fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-chinese-addons fcitx5-configtool fcitx5-mozc ];
  #};
  services.dunst = {
    enable = false;
    settings = {
      global = {
        origin = "bottom-right";
        monitor = 1;
        follow = "mouse";
      };
    };
  };
  services.flameshot.enable = true;
  services.picom = {
    enable = true;
    backend = "glx";
    settings = {
      blur = {
        method = "dual_kawase";
        strength = 7;
      };
    };
  };
  programs.rofi = {
    enable = true;
    # package = pkgs.rofi-wayland;
  };

  systemd.user.services.sxhkd = {
    Unit = {
      Description = "sxhkd daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.sxhkd}/bin/sxhkd";
    };
  };
  #services.sxhkd.enable = true;
  #services.polybar.enable = true;
  #services.polybar.config = "${./bspwm-starter-pack/polybar}/config.ini";
  systemd.user.services.x11vnc = {
    Unit = {
      Description = "X11VNC";
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "exec";
      ExecStart =
        let
          systemctl = "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} systemctl";
        in
        pkgs.writeScript "x11vnc-start" ''
          #! ${pkgs.runtimeShell} -el
          ${pkgs.x11vnc}/bin/x11vnc -usepw -display $DISPLAY -auth $XAUTHORITY -nevershared -forever
        '';
    };
  };
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      rustaceanvim
      rust-vim
    ];
  };
  programs.fish.enable = true;
  programs.bash = {
    bashrcExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  programs.wezterm.enable = true;
  programs.wezterm.package = specialArgs.inputs.wezterm.packages.${pkgs.system}.default;
}
