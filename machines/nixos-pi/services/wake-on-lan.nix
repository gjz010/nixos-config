{ config, pkgs, ... }:
let
  secrets = config.passthru.gjz010.secretsEmbedded.default.nixos-pi;
in
{
  virtualisation.oci-containers.containers = {
    "wol-web" = {
      image = "ghcr.io/gjz010-forks/wol-web:latest";
      extraOptions = [ "--network=host" ];
      volumes = [ "/srv/wol-web/pb_data:/app/pb_data" ];
      environment = {
        PORT = "8091";
      };
    };
  };
}
