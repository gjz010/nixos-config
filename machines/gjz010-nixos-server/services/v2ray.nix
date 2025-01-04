{ config, pkgs, ... }:
let
  clients = [
    {
      id = config.sops.placeholder."tunnel/users/user1";
      alterId = 0;
    }
    {
      id = config.sops.placeholder."tunnel/users/user2";
      alterId = 0;
    }
    {
      id = config.sops.placeholder."tunnel/users/user3";
      alterId = 0;
    }
  ];
  clientsFr = [
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
        listen = config.sops.placeholder."tunnel/directAddr";
        protocol = "vmess";
        settings = {
          inherit clients;
        };
        tag = "tunnel-direct-ipv6";
        inherit streamSettings;
      }
      # fr direct node
      {
        port = 19888;
        listen = config.sops.placeholder."tunnel/directAddr";
        protocol = "vmess";
        settings = {
          inherit clients;
        };
        tag = "tunnel-fr-direct-ipv6";
        inherit streamSettings;
      }
      {
        port = 18888;
        listen = "127.0.0.1";
        protocol = "vmess";
        settings = {
          inherit clients;
        };
        tag = "tunnel-udp2raw";
        inherit streamSettings;
      }
      {
        port = 18889;
        listen = "127.0.0.1";
        protocol = "vmess";
        settings = {
          inherit clients;
        };
        tag = "tunnel-websocket";
        streamSettings = {
          network = "ws";
          security = "none";
          wsSettings = {
            path = config.sops.placeholder."tunnel/httpPath";
          };
        };
        sniffing = {
          enabled = true;
          destOverride = [
            "http"
            "tls"
          ];
        };
      }
    ];
    outbounds = [
      {
        protocol = "freedom";
        settings = { };
        tag = "direct";
      }
      {
        protocol = "vmess";
        settings = {
          vnext = [
            {
              port = 18888;
              address = config.sops.placeholder."tunnel_fr/directAddr";
              users = clientsFr;
            }
          ];
        };
        tag = "tunnel-fr-out";
        inherit streamSettings;
      }
    ];
    routing = {
      rules = [
        {
          type = "field";
          inboundTag = [
            "tunnel-direct-ipv6"
            "tunnel-udp2raw"
            "tunnel-websocket"
          ];
          outboundTag = "direct";
        }
        {
          type = "field";
          inboundTag = [ "tunnel-fr-direct-ipv6" ];
          outboundTag = "tunnel-fr-out";
        }
      ];
    };
  };
  sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
  sopsConfigFr = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config-miniserver-fr.yaml";
  };
in
{
  sops.secrets."tunnel/directAddr" = sopsConfig;
  sops.secrets."tunnel/users/user1" = sopsConfig;
  sops.secrets."tunnel/users/user2" = sopsConfig;
  sops.secrets."tunnel/users/user3" = sopsConfig;
  sops.secrets."tunnel/httpPath" = sopsConfig;

  sops.secrets."tunnel_fr/directAddr" = sopsConfigFr;
  sops.secrets."tunnel_fr/users/user_fr" = sopsConfigFr;

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

  networking.firewall.allowedTCPPorts = [
    18888
    19888
  ];
  networking.firewall.allowedUDPPorts = [
    18888
    19888
  ];

}
