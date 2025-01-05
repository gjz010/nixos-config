let
  transmissionRoot = "/mnt/downloads/transmission/";
in
{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.transmission.enable = true;
  services.transmission.settings = {
    rpc-enabled = true;
    rpc-bind-address = "unix:/var/lib/transmission/transmission-rpc.socket";
    rpc-socket-mode = "0770";
    rpc-whitelist = "*";
    download-dir = "${transmissionRoot}/Downloads";
    incomplete-dir = "${transmissionRoot}/.incomplete";
    message-level = 5;
    dht-enabled = false;
    encryption = 2;
    pex-enabled = false;
    port-forwarding-enabled = false;
    rpc-host-whitelist-enabled = false;
  };
  #  services.transmission.package = pkgs.transmission_4.overrideAttrs (final: prev: {
  #    version = "4.0.5";
  #    src = pkgs.fetchFromGitHub {
  #      owner = "transmission";
  #      repo = "transmission";
  #      rev = final.version;
  #      hash = "sha256-gd1LGAhMuSyC/19wxkoE2mqVozjGPfupIPGojKY0Hn4=";
  #      fetchSubmodules = true;
  #    };
  #  });
  # Disable all incoming traffic.
  services.transmission.openPeerPorts = false;
  # Only allows IPv6 traffic for transmission.
  systemd.services.transmission.serviceConfig.RestrictAddressFamilies =
    lib.mkForce "AF_UNIX AF_INET6";
  services.caddy = {
    enable = true;
    virtualHosts."caddy-transmission" = {
      extraConfig = ''
        bind 192.168.76.1
        reverse_proxy unix//var/lib/transmission/transmission-rpc.socket
      '';
      logFormat = ''
        output file ${config.services.caddy.logDir}/access-caddy-transmission.log
      '';
      hostName = "http://192.168.76.1:9091";
    };
  };
  users.users.caddy.extraGroups = [ "transmission" ];
}
