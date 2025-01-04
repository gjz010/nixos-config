{
  lib,
  pkgs,
  config,
  ...
}:
let
  secrets = config.passthru.gjz010.secretsEmbedded.default.nixos-pi;
  domain = secrets.private-mumble-address;
  enable = false;
in
{
  services.jitsi-meet = {
    enable = enable;
    hostName = "${domain}";
    config.websocket = "wss://${domain}:7777/xmpp-websocket";
    config.bosh = "//${domain}:7777/http-bind";
  };
  networking.firewall.allowedTCPPorts = [ 7777 ];
  services.jitsi-meet.caddy.enable = enable;
  services.caddy.virtualHosts."${domain}" = {
    useACMEHost = "${domain}";
    #extraConfig = ''
    #    tls /var/lib/acme/${domain}/fullchain.pem /var/lib/acme/${domain}/key.pem
    #'';
    serverAliases = [ "${domain}:7777" ];
  };
  #services.jicofo.userDomain = lib.mkForce null;
  services.jitsi-meet.nginx.enable = enable;
  services.jitsi-videobridge.openFirewall = enable;
  nixpkgs.config.permittedInsecurePackages = [
    "jitsi-meet-1.0.8043"
  ];
}
