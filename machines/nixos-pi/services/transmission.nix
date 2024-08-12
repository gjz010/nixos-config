let
  transmissionRoot = "/mnt/downloads/transmission/";
in
{lib, pkgs, ...}:
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
  services.transmission.package = pkgs.transmission_4;
  # Disable all incoming traffic.
  services.transmission.openPeerPorts = false;
  # Only allows IPv6 traffic for transmission.
  systemd.services.transmission.serviceConfig.RestrictAddressFamilies = lib.mkForce "AF_UNIX AF_INET6";
  services.caddy = {
    enable = true;
    virtualHosts."http://192.168.76.1:9091".extraConfig = ''
        bind 192.168.76.1
        reverse_proxy unix//var/lib/transmission/transmission-rpc.socket
    '';
  };
  users.users.caddy.extraGroups = ["transmission"];
}
