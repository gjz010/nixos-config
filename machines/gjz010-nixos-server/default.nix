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
    ./services/conduit.nix
    ./services/qqbridge.nix
    ./services/phantun.nix
    ./services/mongo.nix
    ./services/iroh-relay.nix
    ./services/tor-bridge.nix

  ];
}
