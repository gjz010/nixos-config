# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    firefox
    gitFull
    sops
    proxychains-ng
  ];
  programs.nix-ld.enable = true;
  programs.direnv.enable = true;
  services.openssh.enable = true;
  services.openssh.ports = [
    22
    2223
  ];
  nix = {
    settings.trusted-users = [ "gjz010" ];
  };
  system.stateVersion = "24.05";

}
