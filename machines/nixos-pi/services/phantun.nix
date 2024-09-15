{pkgs, lib, config, ...}:
let 
  phantunClientTun = "192.168.200.2";
  phantunClient6Tun = "fcc8::2";
  phantunServerTun =  "192.168.201.2";
  phantunServer6Tun = "fcc9::2";
  sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
  phantunClientScript = pkgs.writeShellScript "phantun-client-launch" ''
    exec ${pkgs.gjz010.pkgs.phantun}/bin/phantun-client --local 127.0.0.1:19000 --remote $listenAddr:$port
  '';
in
{

  sops.secrets."tunnel/phantun/listenAddr" = sopsConfig;
  sops.secrets."tunnel/phantun/port" = sopsConfig;

  sops.templates."phantun-client.env".content = ''
    RUST_LOG = info
    listenAddr = ${config.sops.placeholder."tunnel/phantun/listenAddr"}
    port = ${config.sops.placeholder."tunnel/phantun/port"}
  '';
  sops.templates."phantun-client.nft".content = ''
    define phantun_server = ${config.sops.placeholder."tunnel/phantun/listenAddr"}
    define phantun_port = ${config.sops.placeholder."tunnel/phantun/port"}
  '';
  systemd.services.phantun-client = {
    enable = true;
    description = "Phantun client";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "nss-lookup.target" ];
    serviceConfig = {
      ExecStart = phantunClientScript;
      EnvironmentFile = config.sops.templates."phantun-client.env".path;
      Restart = "always";
      RestartSec = "10s";
      DynamicUser = true;
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
    };
  };
  #networking.nftables.checkRuleset = false;
  networking.nftables.tables."phantun-client" = {
    family = "inet";
    content = 
    ''
      include "${config.sops.templates."phantun-client.nft".path}"
      chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          iifname tun1 oifname end0 masquerade
      }
    '';
  };
}