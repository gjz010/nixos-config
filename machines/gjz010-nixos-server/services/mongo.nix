{ pkgs, config, ... }:
let
  secrets = config.passthru.gjz010.secretsEmbedded.default.gjz010-nixos-server;
  password = secrets.mongodb-initial-password;
in
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "mongodb"
    ];
  services.mongodb = {
    enable = true;
    enableAuth = true;
    initialRootPassword = password;
  };
}
