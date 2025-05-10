{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  botamusique_pkg = pkgs.gjz010.pkgs.botamusique;
  secrets = config.passthru.gjz010.secretsEmbedded.default.nixos-pi;
  domain = secrets.private-mumble-address;
  cert_sops_path = config.sops.secrets."private-mumble-cert".path;
in
{
  sops.secrets."private-mumble-cert" = {
    format = "binary";
    sopsFile = "${config.passthru.gjz010.secretRoot}/botamusique/botamusique.pem";
  };
  services.murmur.enable = true;
  services.murmur.openFirewall = true;
  services.murmur.clientCertRequired = true;
  services.murmur.registerHostname = "${domain}";
  services.murmur.password = "${secrets.private-mumble-password}";
  services.murmur.bandwidth = 558000;
  services.botamusique = {
    enable = true;
    package = botamusique_pkg;
    settings = {
      webinterface.enabled = true;
      server.channel = "说的道理音乐电台";
      server.password = "${secrets.private-mumble-password}";
      webinterface.listening_addr = "192.168.80.1";
      bot.music_folder = "/var/lib/private/botamusique/music_folder/";
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
  networking.nat = {
    internalInterfaces = [ "ve-*" ];
    #enableIPv6 = true;
  };
  /*
    containers.botamusique-remote = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.201.1";
    localAddress = "192.168.201.2";
    bindMounts."/etc/botamusique/cert.pem" = {
      hostPath = cert_sops_path;
      isReadOnly = true;
    };
    # https://gist.github.com/clamydo/9691c48552efcd6d338407d58c900a4a
    extraFlags = [
      "--load-credential=botamusique-container.pem:${cert_sops_path}"
    ];
    config =
      { config
      , pkgs
      , lib
      , ...
      }:
      {
        services.botamusique = {
          enable = true;
          package = botamusique_pkg;
          settings = {
            webinterface.enabled = true;
            server.host = "${secrets.public-mumble-address}";
            server.channel = "王小桃音乐电台";
            server.password = "${secrets.public-mumble-password}";
            webinterface.listening_addr = "192.168.201.2";
            bot.music_folder = "/var/lib/private/botamusique/music_folder/";
            bot.max_track_duration = 10000;
          };
        };
        systemd.services.botamusique = {
          serviceConfig = {
            LoadCredential = "botamusique.pem:botamusique-container.pem";
            ExecStart = lib.mkForce "${config.services.botamusique.package}/bin/botamusique --config ${
              (pkgs.formats.ini { }).generate "botamusique.ini" config.services.botamusique.settings
            } -C \${CREDENTIALS_DIRECTORY}/botamusique.pem";
          };
        };
        networking.useHostResolvConf = lib.mkForce false;
        networking.firewall.enable = true;
        networking.firewall.allowedTCPPorts = [ 8181 ];
        services.resolved.enable = true;
        system.stateVersion = "24.11";
      };
    };
  */
}
