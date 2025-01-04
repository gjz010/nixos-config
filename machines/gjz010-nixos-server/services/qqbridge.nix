{ config, pkgs, ... }:
let
  # This port is UDP.
  kcptun_udp2raw_port = "18890";
  # This port is TCP.
  qqbridge_port = "18890";
  sopsConfig = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/tunnel-config/config.yaml";
  };
  udp2rawScript = pkgs.writeShellScript "udp2raw-launch" ''
    exec ${pkgs.udp2raw}/bin/udp2raw -c -l 127.0.0.1:${kcptun_udp2raw_port} -r $remote_addr:18890 --raw-mode faketcp -k $key --seq-mode 4 --fix-gro
  '';
in
{
  sops.secrets."udp2raw-qqbridge/remoteAddr" = sopsConfig;
  sops.secrets."udp2raw-qqbridge/kcpKey" = sopsConfig;
  sops.secrets."udp2raw-qqbridge/key" = sopsConfig;

  sops.templates."udp2raw-qqbridge.env".content = ''
    remote_addr=${config.sops.placeholder."udp2raw-qqbridge/remoteAddr"}
    key=${config.sops.placeholder."udp2raw-qqbridge/key"}
  '';
  sops.templates."kcptun-qqbridge.env".content = ''
    KCPTUN_KEY=${config.sops.placeholder."udp2raw-qqbridge/kcpKey"}
  '';

  systemd.services.kcptun-qqbridge = {
    enable = true;
    description = "Kcptun Client connecting to QQBridge";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "nss-lookup.target"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.gjz010.pkgs.kcptun-bin}/bin/kcptun-client -l 127.0.0.1:${qqbridge_port} -r 127.0.0.1:${kcptun_udp2raw_port} --mode fast3";
      EnvironmentFile = config.sops.templates."kcptun-qqbridge.env".path;
      Restart = "always";
      RestartSec = 10;
    };
  };
  systemd.services.udp2raw-qqbridge = {
    enable = true;
    description = "UDP2Raw Client connecting to QQBridge";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "nss-lookup.target"
    ];
    serviceConfig = {
      ExecStart = udp2rawScript;
      EnvironmentFile = config.sops.templates."udp2raw-qqbridge.env".path;
      Restart = "always";
      RestartSec = 10;
    };
  };

}
