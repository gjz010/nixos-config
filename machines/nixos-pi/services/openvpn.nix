{
  config,
  lib,
  pkgs,
  ...
}:
let
  certSecretName = crt: "openvpn-cert-${crt}";
  createCert = crt: {
    "${certSecretName crt}" = {
      format = "binary";
      sopsFile = "${config.passthru.gjz010.secretRoot}/openvpn/certs/${crt}";
    };
  };
  vpnCert = crt: config.sops.secrets."${certSecretName crt}".path;
  allCerts = [
    (createCert "ca.pem")
    (createCert "server.pem")
    (createCert "dh2048.pem")
    (createCert "server-key.pem")
    (createCert "openvpn-remote.key")
  ];
  vpn-dev = "tun0";
  vpn-dev-tcp = "tun1";
  vpnPort = 1194;
in
{
  networking.firewall.allowedUDPPorts = [ vpnPort ];
  networking.firewall.allowedTCPPorts = [ vpnPort ];
  sops.secrets = lib.attrsets.mergeAttrsList allCerts;
  environment.systemPackages = [ pkgs.openvpn ];

  services.openvpn.servers.remote.config = ''
    tls-server
    dev ${vpn-dev}
    server 192.168.78.0 255.255.255.0
    ifconfig-pool-persist /var/openvpn-remote.txt
    dh ${vpnCert "dh2048.pem"}
    ca ${vpnCert "ca.pem"}
    cert ${vpnCert "server.pem"}
    key ${vpnCert "server-key.pem"}
    cipher AES-256-CBC
    auth-nocache
    comp-lzo
    keepalive 10 60
    ping-timer-rem
    persist-tun
    persist-key
  '';
  services.openvpn.servers.remote-tcp.config = ''
    tls-server
    proto tcp
    topology subnet
    server 192.168.79.0 255.255.255.0
    dev ${vpn-dev-tcp}
    ifconfig-pool-persist /var/openvpn-remote-tcp.txt
    status /var/openvpn-remote-tcp-status.log
    verb 6
    dh ${vpnCert "dh2048.pem"}
    ca ${vpnCert "ca.pem"}
    cert ${vpnCert "server.pem"}
    key ${vpnCert "server-key.pem"}
    cipher AES-256-CBC 
    auth-nocache
    comp-lzo
    keepalive 10 60
    ping-timer-rem 
    persist-tun
    persist-key
    push "route 192.168.76.0 255.255.255.0"
    push "route 192.168.77.0 255.255.255.0"
    push "route 192.168.78.0 255.255.255.0"

  '';
}
