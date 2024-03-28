{config, ...}:
{
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = null;
  };
  home-manager.users.alice = { pkgs, ... }: {
    home.packages = [ pkgs.cowsay ];
    programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = config.system.stateVersion;
  };
}