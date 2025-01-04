{ pkgs, config, ... }:
let
  sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
  udp2rawClientScript = pkgs.writeShellScript "udp2raw-client-launch" ''
    exec ${pkgs.udp2raw}/bin/udp2raw -c -l 127.0.0.1:30084 -r $remote_addr:1 --raw-mode icmp -k $key --fix-gro --seq-mode 4
  '';
in
{
  sops.templates."udp2raw-client.env".content = ''
    remote_addr=${config.sops.placeholder."tunnel/udp2raw/listenAddr"}
    key=${config.sops.placeholder."tunnel/udp2raw/key"}
  '';
  sops.templates."udp2raw-var.nft".content = ''
    define udp2raw_peer = ${config.sops.placeholder."tunnel/udp2raw/listenAddr"}
  '';
  sops.secrets."tunnel/udp2raw/key" = sopsConfig;
  sops.secrets."tunnel/udp2raw/listenAddr" = sopsConfig;
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
    family = "ip";
    content = ''
      include "${config.sops.templates."udp2raw-var.nft".path}"
      chain user_post_input {
          type filter hook input priority 1; policy accept;
          ip saddr $udp2raw_peer icmp type echo-reply drop;
          ct state new log prefix "Firewall4 accepted ingress: ";
      }
    '';
  };
}
