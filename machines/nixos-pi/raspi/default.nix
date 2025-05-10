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
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = [
    "console=ttyAMA0,115200n8"
    "console=ttyS0,115200n8"
    "console=tty0"
    "console=tty1"
    "cma=128M"
  ];
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  sdImage.compressImage = false;
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ./hardware-configuration.nix
  ];
  boot.supportedFilesystems.zfs = lib.mkForce false;
  passthru.router = {
    networkInterfaces = {
      wan = "end0";
      lan = "enp1s0u2c2";
      wlan = "wlan0";
    };
    transmissionPath = "/mnt/downloads/transmission/";
  };
}
