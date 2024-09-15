{ pkgs, lib, config, ... }:
let
  sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
  udp2rawScript = pkgs.writeShellScript "udp2raw-launch" ''
    exec ${pkgs.udp2raw}/bin/udp2raw -s -l $listen_addr:1 -r 127.0.0.1:18888 --raw-mode icmp -k $key --seq-mode 4 --fix-gro
  '';
in
{
  sops.templates."udp2raw.env".content = ''
    listen_addr=${config.sops.placeholder."tunnel/udp2raw/listenAddr"}
    key=${config.sops.placeholder."tunnel/udp2raw/key"}
  '';
  sops.secrets."tunnel/udp2raw/key" = sopsConfig;
  sops.secrets."tunnel/udp2raw/listenAddr" = sopsConfig;

  systemd.services.udp2raw = {
    enable = true;
    description = "udp2raw";
    after = [ "network.target" "nss-lookup.target" ];
    serviceConfig = {
      ExecStart = udp2rawScript;
      EnvironmentFile = config.sops.templates."udp2raw.env".path;
      Restart = "always";
      RestartSec = "10s";
    };
    wantedBy = [ "multi-user.target" ];
  };


  networking.nftables.tables."udp2raw-nftables" = {
    enable = true;
    family = "ip";
    content = ''
      chain user_post_input {
          type filter hook input priority 1; policy accept;
          meta iifname enp1s0 icmp type echo-request drop;
      }
    '';
  };
}
