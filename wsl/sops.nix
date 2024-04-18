{ config, pkgs, lib, ... }:
{
    sops.defaultSopsFile = ./secrets/example.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    sops.secrets.example_key = {};
    users.mutableUsers = false;
    sops.secrets."shadow/gjz010" = {
        sopsFile = ./secrets/shadow.yaml;
        neededForUsers = true;
    };
}
