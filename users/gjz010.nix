{config, ...}:
{
  users.users."gjz010" = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "REDACTED";
  };
  home-manager.users."gjz010" = { pkgs, ... }: {
    home.packages = [ pkgs.cowsay ];
    programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = config.system.stateVersion;
  };
}