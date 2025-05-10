{
  lib,
  inputs,
  specialArgs,
  ...
}:
let
  variant = specialArgs.variant;
  variantConfig =
    if variant == "raspi" then
      ./raspi
    else if variant == "amd64" then
      ./amd64
    else
      builtins.trace "Invalid variant: ${variant}";
in
{

  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure =
        x:
        super.makeModulesClosure (
          x
          // {
            allowMissing = true;
          }
        );
    })
  ];

  imports = [
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
    ./services/web.nix
    ./services/wake-on-lan.nix
    ./users/gjz010.nix
    variantConfig
  ];
}
