{ config, ... }:
{
  imports = [
    # From nixos-generate-config
    ./configuration.nix

    # User with home-manager
    ./users/gjz010.nix
    ./services/v2ray.nix
    ./services/udp2raw.nix
    ./services/caddy.nix
    ./services/qqbridge.nix
  ];
}

