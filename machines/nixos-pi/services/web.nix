{ config, ... }:
let
  secrets = config.passthru.gjz010.secretsEmbedded.default.nixos-pi;
  domain = secrets.private-mumble-address;
in
{
  networking.firewall.allowedTCPPorts = [ 8090 ];
  services.caddy.virtualHosts = {
    "${domain}:8090" = {
      extraConfig = ''
        encode gzip
        root * /srv/http
        file_server browse
      '';
    };
  };
}
