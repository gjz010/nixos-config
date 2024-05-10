{ config, ... }:
{
  imports = [
    # From nixos-generate-config
    ./configuration.nix
    ./nixos-wsl.nix
    # User with home-manager
    ./users/gjz010.nix
    ./services/redis.nix
  ];
}
