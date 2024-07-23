{ config, pkgs, ... }:
let
  thuconfig = config.sops.secrets."auththu.json".path;
  auth-thu = pkgs.stdenvNoCC.mkDerivation {
    name = "auth-thu";
    version = "v2.2.1";
    src = pkgs.fetchurl {
      url = "https://github.com/z4yx/GoAuthing/releases/download/v2.2.1/auth-thu.linux.arm64";
      hash = "sha256-QVap64sN1QGxb9WD6RG25Fyr4sgJ5pAC+coXpd3Gu68=";
    };
    unpackPhase = "true";
    buildPhase = "true";
    installPhase = "install -Dm755 $src $out/bin/auth-thu";
  };
in
{
  sops.secrets."auththu.json" = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/router/auththu.yaml";
  };
  systemd.services.auth-thu = {
    enable = true;
    description = "auth-thu";
    unitConfig = {
      After = [ "network.target" "nss-lookup.target" ];
    };
    serviceConfig = {
      ExecStartPre = [
        "-${auth-thu}/bin/auth-thu -c ${thuconfig} -D auth"
        "-${auth-thu}/bin/auth-thu -c ${thuconfig} -D login"
      ];
      ExecStart = "${auth-thu}/bin/auth-thu -c ${thuconfig} -D online";
      Restart = "always";
      RestartSec = 5;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
