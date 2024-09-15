{ config, pkgs, ... }:
let
  enableSniffing = {
    enabled = true;
    destOverride = [ "http" "tls" ];
  };
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
  clientAuth = { id = config.sops.placeholder."tunnel/users/user1"; alterId = 0; };
  clientConfig =
    {
      log = {
        loglevel = "debug";
      };
      inbounds = [
        {
          port = 30086;
          protocol = "http";
          settings = {
            ip = "192.168.76.1";
          };
          sniffing = enableSniffing;
        }
        {
          port = 30085;
          listen = "192.168.76.1";
          protocol = "socks";
          settings = {
            auth = "password";
            accounts = [
              { user = config.sops.placeholder."router/tunnel/socks/user"; pass = config.sops.placeholder."router/tunnel/socks/pass"; }
            ];
            udp = true;
            ip = "192.168.76.1";
          };
          sniffing = enableSniffing;
        }
      ];
      outbounds = [
        {
          tag = "direct";
          protocol = "vmess";
          settings = {
            vnext = [
              {
                users = [ clientAuth ];
                address = "127.0.0.1";
                port = 19000;
              }
            ];
          };
          inherit streamSettings;
        }
        {
          tag = "blocked";
          settings = { };
          protocol = "blackhole";
        }
        {
          tag = "dns-out";
          protocol = "dns";
        }
      ];
      routing = {
        domainStrategy = "IPOnDemand";
        rules = [
          {
            type = "field";
            port = 53;
            outboundTag = "dns-out";
          }
          {
            type = "field";
            domain = [ "geosite:category-ads" ];
            outboundTag = "blocked";
          }
        ];
      };
      dns = {
        servers = [ "https://1.0.0.1/dns-query" ];
      };
    };
  sopsTunnelConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
  sopsRouterConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/router/router.yaml";
  };
  v2rayAssets = pkgs.runCommand "v2ray-assets" { } ''
    mkdir -p $out/share/v2ray
    cd ${pkgs.v2ray-geoip}/share/v2ray/
    for i in *.dat; do
      ln -s $i $out/share/v2ray/$i
    done
    ln -s ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat $out/share/v2ray/geosite.dat
  '';
in
{
  sops.secrets."tunnel/users/user1" = sopsTunnelConfig;
  sops.secrets."router/tunnel/socks/user" = sopsRouterConfig;
  sops.secrets."router/tunnel/socks/pass" = sopsRouterConfig;

  sops.templates."tunnel-client.yaml".content = builtins.toJSON clientConfig;
  sops.templates."tunnel-client.yaml".owner = "v2ray";
  services.v2ray.enable = true;
  services.v2ray.configFile = config.sops.templates."tunnel-client.yaml".path;
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
    environment = {
      V2RAY_LOCATION_ASSET = "${v2rayAssets}/share/v2ray";
    };
  };

}
