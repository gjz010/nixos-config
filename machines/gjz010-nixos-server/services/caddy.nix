{ pkgs, config, ... }:
{
  services.caddy = rec {
    enable = true;
    virtualHosts."matrix.gjz010.com".extraConfig = ''
      encode gzip
      reverse_proxy /_matrix/client/unstable/org.matrix.msc3575/sync http://127.0.0.1:8009
      reverse_proxy /client/* http://127.0.0.1:8009
      reverse_proxy /_matrix/* http://127.0.0.1:8008
      reverse_proxy /_synapse/client/* http://127.0.0.1:8008
      header /.well-known/matrix/* Content-Type application/json
      header /.well-known/matrix/* Access-Control-Allow-Origin *
      respond /.well-known/matrix/server `{"m.server": "matrix.gjz010.com:443"}`
      respond /.well-known/matrix/client `{"m.homeserver":{"base_url":"https://matrix.gjz010.com"},"org.matrix.msc3575.proxy":{"url":"https://matrix.gjz010.com"}}`
    '';
    virtualHosts."matrix.gjz010.com:8448".extraConfig = virtualHosts."matrix.gjz010.com".extraConfig;
  };
  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}
