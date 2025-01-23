{ config, pkgs, ... }:
let
  secrets = config.passthru.gjz010.secretsEmbedded.default.nixos-pi;
in
{
  virtualisation.oci-containers.containers = {
    "wol-web" = {
      image = "ghcr.io/gjz010-forks/wol-web@sha256:8739493ab652b6515bc2734d3936999167541f266f3270d42d1b0acbad5ee970";
      extraOptions = [ "--network=host" ];
      volumes = [ "/srv/wol-web/pb_data:/app/pb_data" ];
      environment = {
        PORT = "8091";
      };
    };
  };
}
