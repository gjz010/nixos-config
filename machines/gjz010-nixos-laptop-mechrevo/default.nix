{ config, ... }:
{
  imports = [
    ./configuration.nix
    ./disko.nix
    ./users/gjz010.nix
    ./crucial.nix
  ];
}
