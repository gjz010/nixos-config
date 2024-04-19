{pkgs, lib, config, ...}:
let
sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml"
};
udp2rawScript = pkgs.writeShellScript "udp2raw-launch" ''
    exec ${pkgs.udp2raw}/bin/udp2raw -s -l $listen_addr -r 127.0.0.1:18888 --raw-mode icmp -k $key --sqe-mode 4 --fix-gro
'';
in
{
    sops.templates."udp2raw.env".content = ''
        listen_addr=${config.sops.placeholder."tunnet/udp2raw/listenAddr"}
        key=${config.sops.placeholder."tunnel/udp2raw/key"}
    '';
    sops.secrets."tunnel/udp2raw/key" = sopsConfig;
    sops.secrets."tunnel/udp2raw/listenAddr" = sopsConfig;
    systemd.services.udp2raw = {
        enable = true;
        description = "udp2raw";
        unitConfig = {
            after = [ "network.target" "nss-lookup.target" ];
        };
        serviceConfig = {
            ExecStart = udp2rawScript;
        };
        wantedBy = [ "multi-user.target" ];
    };
    networking.nftables.tables."udp2raw-v4" = {
        family = "ip";
        content = 
        ''
            chain user_post_input {
                type filter hook input priority 1; policy accept;
                ip saddr 45.32.17.8 icmp type echo-reply drop;
                ct state new log prefix "Udp2raw ingress: ";
            }
        '';
    };

}
