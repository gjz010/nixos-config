{ config, ... }:
let
  secrets = config.passthru.gjz010.secretsEmbedded.default.nixos-pi;
  domain = secrets.private-mumble-address;
  password-hashed = secrets.owncast-password-hashed;
  port = 10033;
in
{
  networking.firewall.allowedTCPPorts = [
    port
    10034
  ];
  networking.nat.forwardPorts = [
    {
      sourcePort = 10034;
      proto = "tcp";
      destination = "192.168.77.95:1935";
    }
  ];
  services.caddy = {
    enable = true;
    virtualHosts."${domain}:${builtins.toString port}" = {
      extraConfig = ''
        encode gzip
        reverse_proxy http://192.168.77.95:7080
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
