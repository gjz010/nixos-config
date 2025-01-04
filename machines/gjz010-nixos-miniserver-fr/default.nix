{ config, ... }:
{
  imports = [
    ./configuration.nix
    ./disko.nix
    ./users/gjz010.nix
    ./services/v2ray.nix
  ];
}
