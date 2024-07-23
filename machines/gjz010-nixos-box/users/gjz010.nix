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
    home.packages = with pkgs; [ cowsay vscodium zotero_7 ripgrep gjz010.pkgs.proxychains-wrapper gjz010.pkgs.icalinguapp ];
    programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = config.system.stateVersion;
  };
}
