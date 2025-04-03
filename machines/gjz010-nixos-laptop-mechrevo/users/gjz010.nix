{ config, ... }:
{
  users.users."gjz010" = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    hashedPasswordFile = config.sops.secrets."shadow/gjz010-nixos-laptop-mechrevo/gjz010".path;
  };
  sops.secrets."shadow/gjz010-nixos-laptop-mechrevo/gjz010" = {
    neededForUsers = true;
  };
  home-manager.users."gjz010" =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        cowsay
        vscodium
        zotero_7
        ripgrep
        gjz010.pkgs.proxychains-wrapper
        gjz010.pkgs.icalinguapp
        kdePackages.spectacle
        #yesplaymusic
        #gjz010.pkgs.yesplaymusic-osd
        #osdlyrics
        kdePackages.polkit-kde-agent-1
        flameshot
        hyprpaper
        rofi-wayland
        grimblast
        hyprlock
        grim
        imagemagick
        pavucontrol
        qpwgraph
        xournalpp
        mumble
      ];
      programs.bash.enable = true;
      fonts.fontconfig.enable = true;
      /*
        programs.waybar.enable = true;
        services.dunst = {
          enable = true;
          settings = {
            global = {
              origin = "bottom-right";
            };
          };
        };
      */
      home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 16;
      };

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = config.system.stateVersion;
    };
}
