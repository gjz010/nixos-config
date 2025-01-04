{ config, pkgs, ... }:
let
  clients = [
    {
      id = config.sops.placeholder."tunnel_fr/users/user_fr";
      alterId = 0;
    }
  ];
  streamSettings = {
    network = "mkcp";
    kcpSettings = {
      uplinkCapacity = 5;
      downlinkCapacity = 100;
      congestion = true;
      header = {
        type = "none";
      };
    };
  };
  serverConfig = {
    log = {
      loglevel = "debug";
    };
    inbounds = [
      {
        port = 18888;
        listen = config.sops.placeholder."tunnel_fr/directAddr";
        protocol = "vmess";
        settings = {
          inherit clients;
        };
        tag = "tunnel";
        inherit streamSettings;
      }
    ];
    outbounds = [
      {
        protocol = "freedom";
        settings = { };
        tag = "direct";
      }
    ];
  };
  sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config-miniserver-fr.yaml";
  };
in
{
  sops.secrets."tunnel_fr/directAddr" = sopsConfig;
  sops.secrets."tunnel_fr/users/user_fr" = sopsConfig;

  sops.templates."tunnel.yaml".content = builtins.toJSON serverConfig;
  sops.templates."tunnel.yaml".owner = "v2ray";
  services.v2ray.enable = true;
  services.v2ray.configFile = config.sops.templates."tunnel.yaml".path;

  users.users = {
    v2ray = {
      group = "v2ray";
      isSystemUser = true;
    };
  };

  users.groups = {
    v2ray = { };
  };

  systemd.services.v2ray = {
    serviceConfig = {
      User = "v2ray";
      Group = "v2ray";
    };
  };

  networking.firewall.allowedTCPPorts = [ 18888 ];
  networking.firewall.allowedUDPPorts = [ 18888 ];

}
