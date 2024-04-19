{ config, pkgs, ... }:
let
  clients = [
    { id = config.sops.placeholder."tunnel/users/user1"; alterId = 0; }
    { id = config.sops.placeholder."tunnel/users/user2"; alterId = 0; }
    { id = config.sops.placeholder."tunnel/users/user3"; alterId = 0; }
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
  serverConfig =
    {
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
          inherit streamSettings;
        }
        {
          port = 18888;
          listen = "127.0.0.1";
          protocol = "vmess";
          settings = {
            inherit clients;
          };
          inherit streamSettings;
        }
        {
          port = 18889;
          listen = "127.0.0.1";
          protocol = "vmess";
          settings = {
            inherit clients;
          };
          streamSettings = {
            network = "ws";
            security = "none";
            wsSettings = {
              path = config.sops.placeholder."tunnel/httpPath";
            };
          };
          sniffing = {
            enabled = true;
            destOverride = [ "http" "tls" ];
          };
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
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
in
{
  sops.secrets."tunnel/directAddr" = sopsConfig;
  sops.secrets."tunnel/users/user1" = sopsConfig;
  sops.secrets."tunnel/users/user2" = sopsConfig;
  sops.secrets."tunnel/users/user3" = sopsConfig;
  sops.secrets."tunnel/httpPath" = sopsConfig;


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
