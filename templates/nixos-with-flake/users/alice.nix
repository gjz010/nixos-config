{config, ...}:
{
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
  home-manager.users.alice = { pkgs, ... }: {
    home.packages = [ ];
    programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = config.system.stateVersion;
  };
}