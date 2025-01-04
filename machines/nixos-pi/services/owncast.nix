{ config, ... }:
let
  secrets = config.passthru.gjz010.secretsEmbedded.default.nixos-pi;
  domain = secrets.private-mumble-address;
  password-hashed = secrets.owncast-password-hashed;
  port = 10032;
in
{
  services.owncast.enable = true;
  networking.firewall.allowedTCPPorts = [ port ];
  services.caddy = {
    enable = true;
    virtualHosts."${domain}:${builtins.toString port}" = {
      extraConfig = ''
        encode gzip
        reverse_proxy http://127.0.0.1:8080
        basic_auth {
            guest ${password-hashed}
        }
      '';
      useACMEHost = domain;
    };
  };
  security.acme = {
    certs."${domain}" = {
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.templates."acme-cloudflare".path;
      group = config.services.caddy.group;
    };
  };

}
