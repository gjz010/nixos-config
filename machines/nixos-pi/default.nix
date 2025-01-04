{ lib, inputs, ... }:
{
  boot.supportedFilesystems.zfs = lib.mkForce false;
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  sdImage.compressImage = false;
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ./configuration.nix
    ./services/auth-thu.nix
    ./services/openvpn.nix
    ./services/acme.nix
    ./services/owncast.nix
    ./services/router-nat.nix
    ./services/samba.nix
    ./services/transmission.nix
    ./services/udp2raw.nix
    ./services/v2ray.nix
    ./services/phantun.nix
    ./services/murmur.nix
    ./services/jitsi.nix
    ./users/gjz010.nix
  ];
}
