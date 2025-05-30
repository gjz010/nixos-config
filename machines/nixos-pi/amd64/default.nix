{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}:
let
  inputs = specialArgs.inputs;
in
{
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];
  passthru.router = {
    networkInterfaces = {
      wan = "enp3s0";
      lan = "enp1s0";
      wlan = "wlo1";
    };
    transmissionPath = config.services.transmission.home;
  };
}
