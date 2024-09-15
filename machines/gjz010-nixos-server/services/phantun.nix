{pkgs, lib, config, ...}:
let 
  phantunClientTun = "192.168.200.2";
  phantunClient6Tun = "fcc8::2";
  phantunServerTun =  "192.168.201.2";
  phantunServer6Tun = "fcc9::2";
  sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
  phantunServerScript = pkgs.writeShellScript "phantun-server-launch" ''
    exec ${pkgs.gjz010.pkgs.phantun}/bin/phantun-server --local $port --remote 127.0.0.1:18888
  '';
in
{

  sops.secrets."tunnel/phantun/listenAddr" = sopsConfig;
  sops.secrets."tunnel/phantun/port" = sopsConfig;

  sops.templates."phantun-server.env".content = ''
    RUST_LOG = info
    port = ${config.sops.placeholder."tunnel/phantun/port"}
  '';
  sops.templates."phantun-server.nft".content = ''
    define phantun_server = ${config.sops.placeholder."tunnel/phantun/listenAddr"}
    define phantun_port = ${config.sops.placeholder."tunnel/phantun/port"}
  '';
  systemd.services.phantun-server = {
    enable = true;
    description = "Phantun server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "nss-lookup.target" ];
    serviceConfig = {
      ExecStart = phantunServerScript;
      EnvironmentFile = config.sops.templates."phantun-server.env".path;
      Restart = "always";
      RestartSec = "10s";
      DynamicUser = true;
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
    };
  };
  networking.nftables.checkRuleset = false;
  networking.nftables.tables."phantun-server" = {
    family = "inet";
    content = 
    ''
      include "${config.sops.templates."phantun-server.nft".path}";
      chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;
        ip6 daddr $phantun_server tcp dport $phantun_port counter dnat to ${phantunServer6Tun};
      }
    '';
  };
  networking.firewall.allowedTCPPorts = [ 19000 ];
  # FIXME: Docker by default uses FORWARD drop for ip6tables.
  # switch to Podman to avoid the workaround.
  # https://github.com/moby/moby/issues/48365
  virtualisation.docker.daemon.settings = {
    ip6tables = false;
  };
}
