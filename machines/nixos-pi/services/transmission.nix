let
transmissionRoot = "/mnt/downloads/transmission/";
in
{
  services.transmission.enable = true;
  services.transmission.settings = {
    rpc-bind-address = "0.0.0.0";
    rpc-whitelist = "192.168.*.*,127.0.0.1";
    download-dir = "${transmissionRoot}/Downloads";
    incomplete-dir = "${transmissionRoot}/.incomplete";
  };
  services.transmission.openPeerPorts = true;
}