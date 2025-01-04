{ config, ... }:
{
  users.users."gjz010" = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPasswordFile = config.sops.secrets."shadow/gjz010-nixos-miniserver-fr/gjz010".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZWElmcCzJ4GYjtfERufOXeIZFBeF9YVqYnNU+sPdpg gjz010@nixos-desktop"
    ];
  };
  sops.secrets."shadow/gjz010-nixos-miniserver-fr/gjz010" = {
    neededForUsers = true;
  };
  home-manager.users."gjz010" =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.cowsay ];
      programs.bash.enable = true;

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = config.system.stateVersion;
    };
}
