{ config, ... }:
{
  imports = [
    ./configuration.nix
    ./disko.nix
    ./users/gjz010.nix
    ./services/murmur.nix
  ];
}
