{ config, ... }:
{
  users.users."gjz010" = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    hashedPasswordFile = config.sops.secrets."shadow/gjz010-nixos-pi/gjz010".path;
  };
  sops.secrets."shadow/gjz010-nixos-pi/gjz010" = {
    neededForUsers = true;
  };
  home-manager.users."gjz010" = { pkgs, ... }: {
    home.packages = [ pkgs.cowsay ];
    programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = config.system.stateVersion;
  };
}
