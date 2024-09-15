{ lib, inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./configuration.nix
    ./services/auth-thu.nix
    ./services/openvpn.nix
    # ./services/acme.nix
    # ./services/owncast.nix
    ./services/router-nat.nix
    ./services/samba.nix
    ./services/transmission.nix
    ./services/udp2raw.nix
    ./services/v2ray.nix
    ./services/phantun.nix
    ./users/gjz010.nix
  ];
}
