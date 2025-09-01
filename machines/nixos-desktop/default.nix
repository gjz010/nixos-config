{ lib, specialArgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "wemeet"
      "libwemeetwrap"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];
  imports = [
    ./configuration.nix
    ./sunshine.nix
  ];
}
