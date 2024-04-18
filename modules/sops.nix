flake@{ inputs, self, ... }:
{ config, pkgs, lib, ... }:
let
  secretRoot = "${self}/secrets/";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops.defaultSopsFile = "${secretRoot}/default.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  users.mutableUsers = false;
  /*
    sops.secrets.example_key = {};
    sops.secrets."shadow/gjz010" = {
        sopsFile = "${secretRoot}/shadow.yaml";
        neededForUsers = true;
    };
    */
}
