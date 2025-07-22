{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.teamspeak3 = {
    enable = true;
    openFirewall = true;
  };
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "teamspeak-server"
    ];

}
