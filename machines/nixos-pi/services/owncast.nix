let 
domain = "REDACTED";
port = 80;
in
{
  services.owncast.enable=true;
  networking.firewall.allowedTCPPorts = [ port ];
  services.caddy = {
   enable = true;
   virtualHosts."${domain}:${port}".extraConfig = ''
      encode gzip
      tls /var/lib/acme/${domain}/fullchain.pem /var/lib/acme/${domain}/key.pem
      reverse_proxy http://127.0.0.1:8080
    '';
  };
}