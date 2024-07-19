{config, ...}:
let cloudflare = {
  sopsFile = "${config.passthru.gjz010.secretRoot}/router/router.yaml";
};
in
{
  sops.secrets."router/cloudflare/email" = cloudflare;
  sops.secrets."router/cloudflare/dns_api_token" = cloudflare;
  sops.secrets."router/cloudflare/zone_api_token" = cloudflare;
  sops.templates."acme-cloudflare".content = ''
    CF_API_EMAIL=${config.sops.placeholder."router/cloudflare/email"}
    CF_DNS_API_TOKEN=${config.sops.placeholder."router/cloudflare/dns_api_token"}
    CF_ZONE_API_TOKEN=${config.sops.placeholder."router/cloudflare/zone_api_token"}
  '';
  security.acme = {
    acceptTerms = true;
    # TODO: this module is not enabled for two reasons:
    # 1. This exposes public ip of router.
    # 2. ACME module is not working with sops, specifically the email field.
    defaults.email = "REDACTED";
    certs."REDACTED" = {
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.templates."acme-cloudflare".path;
      group = config.services.caddy.group;
    };
  };
}