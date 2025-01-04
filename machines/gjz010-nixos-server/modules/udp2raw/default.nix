{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.udp2raw;
in
{
  options = {
    services.udp2raw = {
      enable = mkEnableOption (lib.mdDoc "udp2raw tunnels");
      package = mkPackageOption pkgs "udp2raw" { };
      tunnels = mkOption {
        type = with types; attrsOf (submodule (import ./tunnel-options.nix { inherit cfg; }));
      };
    };
  };

}
