flake@{ inputs, self }:
{config, lib, pkgs, ...}:{
  options.services.auth-thu = {
    enable = lib.mkEnableOption "Enable auth-thu.";
    configPath = lib.mkOption {
        type = lib.types.str;
        description = "Configuration for auth-thu.";
    };
    package = lib.mkOption {
        default = inputs.gjz010.packages."config.nixpkgs.system".auth-thu;
        description = "Specify which GoAuthing to use";
        type = lib.types.package;
    };
  };
  options.gjz010.secrets.auth-thu = {
    enable = lib.mkEnableOption ''
        Use repository-included configuration for auth-thu.
        You should not enable this if you are not me.
    '';
  };

  config = (lib.mkIf config.services.auth-thu.enable {
      systemd.services.auth-thu = 
        let
            auth-thu = services.auth-thu.package;
            thuconfig = services.auth-thu.configPath;
        in
        {
            enable = true;
            description = "auth-thu from GoAuthing.";
            unitConfig = {
            After = [ "network.target" "nss-lookup.target" ];
            };
            serviceConfig = {
            ExecStartPre = [
                "-${auth-thu}/bin/auth-thu -c ${thuconfig} -D auth"
                "-${auth-thu}/bin/auth-thu -c ${thuconfig} -D login"
            ];
            ExecStart =  "${auth-thu}/bin/auth-thu -c ${thuconfig} -D online";
            Restart = "always";
            RestartSec = 5;
            };
            wantedBy = [ "multi-user.target" ];
        };
  }) // (lib.mkIf config.gjz010.secrets.auth-thu.enable {
    sops.secrets."auththu.json" = {
        sopsFile = "${config.passthru.gjz010.secretRoot}/router/auththu.yaml";
    };
    services.auth-thu.configPath = config.sops.secrets."auththu.json".path;
  });
}
