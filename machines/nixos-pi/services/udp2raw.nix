{ pkgs, config, ... }:
let
  sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
  isV4 = true;
  listenAddrKey = if isV4 then "tunnel/udp2raw/listenAddrV4" else "tunnel/udp2raw/listenAddr";
  listenFamily = if isV4 then "ip" else "ip6";
  udp2rawClientScript = pkgs.writeShellScript "udp2raw-client-launch" ''
    exec ${pkgs.udp2raw}/bin/udp2raw -c -l 127.0.0.1:30084 -r ${
      if isV4 then "$remote_addr" else "[$remote_addr]"
    }:34286 --raw-mode faketcp -k $key --fix-gro --seq-mode 4
  '';
in
{
  sops.templates."udp2raw-client.env".content = ''
    remote_addr=${config.sops.placeholder."${listenAddrKey}"}
    key=${config.sops.placeholder."tunnel/udp2raw/key"}
  '';
  sops.templates."udp2raw-var.nft".content = ''
    define udp2raw_peer = ${config.sops.placeholder."${listenAddrKey}"}
  '';
  sops.secrets."tunnel/udp2raw/key" = sopsConfig;
  sops.secrets."${listenAddrKey}" = sopsConfig;
  systemd.services.udp2raw = {
    enable = true;
    description = "udp2raw-client";
    after = [
      "network.target"
      "nss-lookup.target"
    ];
    serviceConfig = {
      ExecStart = udp2rawClientScript;
      EnvironmentFile = config.sops.templates."udp2raw-client.env".path;
      Restart = "always";
      RestartSec = "10s";
    };
    wantedBy = [ "multi-user.target" ];
  };
  #networking.nftables.ruleset = ''
  #  include "${config.sops.templates."udp2raw-var.nft".path}"
  #'';
  networking.nftables.checkRuleset = false;
  networking.nftables.tables."udp2raw-v4" = {
    family = listenFamily;
    content = ''
      include "${config.sops.templates."udp2raw-var.nft".path}"
      chain user_post_input {
          type filter hook input priority 1; policy accept;
          ${listenFamily} saddr $udp2raw_peer icmp type echo-reply drop;
      }
    '';
  };
  #ct state new log prefix "Firewall4 accepted ingress: ";
}
