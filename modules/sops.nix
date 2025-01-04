flake@{ inputs, self, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  secretRoot = ../secrets;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops.defaultSopsFile = "${secretRoot}/default.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  users.mutableUsers = false;
  passthru.gjz010.secretRoot = secretRoot;
  passthru.gjz010.secretsEmbedded.default = builtins.fromJSON (
    builtins.readFile "${inputs.secretsEmbedded}/default.json"
  );
  /*
      sops.secrets.example_key = {};
      sops.secrets."shadow/gjz010" = {
        sopsFile = "${secretRoot}/shadow.yaml";
        neededForUsers = true;
      };
  */
}
