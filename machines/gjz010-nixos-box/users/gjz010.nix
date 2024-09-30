{ config, ... }:
{
  users.users."gjz010" = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets."shadow/gjz010-nixos-box/gjz010".path;
  };
  sops.secrets."shadow/gjz010-nixos-box/gjz010" = {
    neededForUsers = true;
  };
  home-manager.users."gjz010" = { pkgs, ... }: {
    home.packages = with pkgs; [ cowsay vscodium zotero_7 ripgrep gjz010.pkgs.proxychains-wrapper
        gjz010.pkgs.icalinguapp kdePackages.spectacle
        #yesplaymusic
        gjz010.pkgs.yesplaymusic-osd
        osdlyrics
        kdePackages.polkit-kde-agent-1 flameshot hyprpaper rofi-wayland
        (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
        font-awesome grimblast hyprlock grim imagemagick pavucontrol qpwgraph
    ];
    programs.bash.enable = true;
    programs.waybar.enable = true;
    services.dunst = {
      enable = true;
      settings = {
        global = {
          origin = "bottom-right";
        };
      };
    };
    fonts.fontconfig.enable = true;
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 16;
    };
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = config.system.stateVersion;
  };
}
