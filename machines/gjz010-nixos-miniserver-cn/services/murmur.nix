{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  botamusique_pkg = pkgs.gjz010.pkgs.botamusique;
  secrets = config.passthru.gjz010.secretsEmbedded.default.gjz010-nixos-miniserver-cn;
  domain = secrets.public-mumble-address;
  cert_sops_path = config.sops.secrets."public-mumble-cert".path;
in
{
  sops.secrets."public-mumble-cert" = {
    format = "binary";
    sopsFile = "${config.passthru.gjz010.secretRoot}/botamusique/botamusique.pem";
  };
  services.murmur.enable = true;
  services.murmur.openFirewall = true;
  services.murmur.clientCertRequired = true;
  services.murmur.registerHostname = "${domain}";
  services.murmur.password = "${secrets.public-mumble-password}";
  services.murmur.extraConfig = ''
    ice="tcp -h 127.0.0.1 -p 6502"
    icesecretread=${secrets.public-mumble-ice-secret-read}
    icesecretwrite=${secrets.public-mumble-ice-secret-write}
  '';
  services.botamusique = {
    enable = true;
    package = botamusique_pkg;
    settings = {
      webinterface.enabled = true;
      server.channel = "王小桃音乐电台";
      server.password = "${secrets.public-mumble-password}";
      webinterface.listening_addr = "192.168.80.7";
      bot.music_folder = "/var/lib/public/botamusique/music_folder/";
      bot.max_track_duration = 10000;
    };
  };
  systemd.services.botamusique = {
    serviceConfig = {
      LoadCredential = "botamusique.pem:${cert_sops_path}";
      ExecStart = lib.mkForce "${config.services.botamusique.package}/bin/botamusique --config ${
        (pkgs.formats.ini { }).generate "botamusique.ini" config.services.botamusique.settings
      } -C \${CREDENTIALS_DIRECTORY}/botamusique.pem";
    };
  };
  networking.firewall.trustedInterfaces = [
    "nebula.nebula-g"
  ];
}
