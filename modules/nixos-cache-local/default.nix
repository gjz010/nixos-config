{config, lib, ...}:{
  options.gjz010.services.nixos-cache-local = {
    enable = lib.mkEnableOption "nixos-cache-local";
    forwardTarget = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:17777";
    };
  };

  config = lib.mkIf config.gjz010.services.nixos-cache-local.enable {
    services.nginx.enable = true;
      services.nginx.virtualHosts."cache.nixos-cache.local" = {
      locations."/" = {
          proxyPass = config.gjz010.services.nixos-cache-local.forwardTarget;
          extraConfig = ''
            proxy_buffering off;
            proxy_pass_header on;
            proxy_set_header Host \"cache.nixos.org\";
            proxy_ssl_server_name on;
          '';
      };
      addSSL = true;
      sslCertificate = "${certs}/server.pem";
      sslCertificateKey = "${certs}/server-key.pem";
      extraConfig = ''
            ssl_client_certificate ${certs}/ca.pem;
            ssl_verify_client on;
      '';
    };
    networking.extraHosts =
    ''
      127.0.0.1 cache.nixos-cache.local
    '';
    security.pki.certificates = [ (builtins.readFile "${certs}/ca.pem")];
  };
}