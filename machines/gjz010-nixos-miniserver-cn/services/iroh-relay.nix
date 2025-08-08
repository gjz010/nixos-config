{ pkgs, config, ... }:
let
  cloudflare = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/iroh/acme.yaml";
  };
  secrets = config.passthru.gjz010.secretsEmbedded.default.iroh-relay;
  certName = secrets.address;
  configToml = pkgs.writeText "iroh-relay-config.toml" ''
    enable_quic_addr_discovery = true
    [tls]
    https_bind_addr = "[::]:7842"
    cert_mode = "Manual"
    manual_cert_path = "${config.security.acme.certs."${certName}".directory}/fullchain.pem"
    manual_key_path = "${config.security.acme.certs."${certName}".directory}/key.pem"
  '';
  iroh-relay = builtins.fetchTarball {
    url = "https://github.com/n0-computer/iroh/releases/download/v0.91.0/iroh-relay-v0.91.0-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "sha256:1i1mzmq9sgbyvd1v3gqiqnq7bjfyp69kh6j20wnawkj0w2xxyl1z";
  };
in
{
  sops.secrets."acme/cloudflare/email" = cloudflare;
  sops.secrets."acme/cloudflare/dns_api_token" = cloudflare;
  sops.secrets."acme/cloudflare/zone_api_token" = cloudflare;
  sops.templates."acme-cloudflare-iroh-relay".content = ''
    CF_API_EMAIL=${config.sops.placeholder."acme/cloudflare/email"}
    CF_DNS_API_TOKEN=${config.sops.placeholder."acme/cloudflare/dns_api_token"}
    CF_ZONE_API_TOKEN=${config.sops.placeholder."acme/cloudflare/zone_api_token"}
  '';
  security.acme = {
    acceptTerms = true;
    # TODO: this module is not enabled for two reasons:
    # 1. This exposes public ip of router.
    # 2. ACME module is not working with sops, specifically the email field.
    defaults.email = "${secrets.acme-email}";
    certs."${certName}" = {
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.templates."acme-cloudflare-iroh-relay".path;
      group = "irohrelay";
    };
  };

  # user and group
  users.users = {
    irohrelay = {
      group = "irohrelay";
      isSystemUser = true;
    };
  };
  users.groups.irohrelay = { };

  systemd.services.iroh-relay = {
    enable = true;
    description = "Iroh relay";
    after = [
      "network.target"
      "acme-finished-${certName}.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "irohrelay";
      Group = "irohrelay";
      Restart = "on-failure";
      RestartSec = 10;
      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateDevices = true;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
    script = ''
      export RUST_LOG=trace
      exec ${iroh-relay}/iroh-relay -c ${configToml}
    '';
  };

  networking.firewall.allowedTCPPorts = [
    9090
    443
    7842
  ];
  networking.firewall.allowedUDPPorts = [ 7842 ];
}
