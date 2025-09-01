flake@{ inputs, self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  nebulaConfig = builtins.fromJSON (builtins.readFile ./network.json);
  #isLightHouse = nebulaConfig."${config.networking.hostName}".lighthouse;
  #isRelay = nebulaConfig."${config.networking.hostName}".relay;
  makeNebulaService =
    { netName, settings }:
    let
      settingsSopsFile = "nebula-sops-${netName}.yaml";
      caSopsFile = "nebula-sops-${netName}-ca.crt";
      certSopsFile = "nebula-sops-${netName}-cert.crt";
      keySopsFile = "nebula-sops-${netName}-key.key";
      netUserName = "nebula-${netName}";
      ddnsV4File = "nebula-cfddns-v4-${netName}";
      ddnsV6File = "nebula-cfddns-v6-${netName}";
      hostName = config.gjz010.nebula.hostName;
      ddnsLauncher = pkgs.writeShellScript "cfddns-launcher" ''
        export PATH=${pkgs.lib.makeBinPath [ pkgs.yq ]}:$PATH
        secretYaml=${config.sops.secrets."${settingsSopsFile}".path}
        domainRoot=$(cat $secretYaml | yq -r ".\"nebula-secrets-global\".domainRoot")
        domainPart=$(cat $secretYaml | yq -r ".\"nebula-secrets-nodes\".\"${hostName}\".secretDomain")
        export CLOUDFLARE_API_TOKEN=$(cat $secretYaml | yq -r ".\"nebula-secrets-global\".\"cloudflare-dyndns-token\"")
        if [ "$1" = "v4" ] ; then
            export CLOUDFLARE_DOMAINS="$domainPart.$domainRoot"
            exec ${pkgs.cloudflare-dyndns}/bin/cloudflare-dyndns --cache-file $STATE_DIRECTORY/ipv4.cache -4 -no-6
        fi
        if [ "$1" = "v6" ] ; then
            export CLOUDFLARE_DOMAINS="ipv6.$domainPart.$domainRoot"
            exec ${pkgs.cloudflare-dyndns}/bin/cloudflare-dyndns --cache-file $STATE_DIRECTORY/ipv6.cache -6 -no-4
        fi
      '';
    in
    {
      sops.secrets."${settingsSopsFile}" = {
        format = "binary";
        sopsFile = settings.secretConfig;
        owner = "${netUserName}";
      };
      sops.secrets."${caSopsFile}" = {
        format = "binary";
        sopsFile = "${settings.certRoot}/ca.crt";
        owner = "${netUserName}";
      };
      sops.secrets."${certSopsFile}" = {
        format = "binary";
        sopsFile = "${settings.certRoot}/certs/${hostName}.crt";
        owner = "${netUserName}";
      };
      sops.secrets."${keySopsFile}" = {
        format = "binary";
        sopsFile = "${settings.certRoot}/keys/${hostName}.key";
        owner = "${netUserName}";
      };
      networking.firewall.allowedUDPPorts = [ 4242 ];
      systemd.services."cloudflare-dyndns-ipv4@${netName}" = {
        description = "Nebula DNSv4 for ${netName}";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        startAt = "*:0/5";
        serviceConfig = {
          Type = "simple";
          User = netUserName;
          Group = netUserName;
          StateDirectory = "cloudflare-dyndns-ipv4@${netName}";
          ExecStart = "${ddnsLauncher} v4";
        };
      };
      systemd.services."cloudflare-dyndns-ipv6@${netName}" = {
        description = "Nebula DNSv6 for ${netName}";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        startAt = "*:0/5";
        serviceConfig = {
          Type = "simple";
          User = netUserName;
          Group = netUserName;
          StateDirectory = "cloudflare-dyndns-ipv6@${netName}";
          ExecStart = "${ddnsLauncher} v6";
        };
      };
      services.nebula.networks."${netName}" = {
        enable = true;
        ca = config.sops.secrets."${caSopsFile}".path;
        cert = config.sops.secrets."${certSopsFile}".path;
        key = config.sops.secrets."${keySopsFile}".path;
        extraSettingsGenerator = pkgs.writeShellScript "nebula-sops" ''
          ${pkgs.gjz010.pkgs.gjz010-nebula-manager}/bin/gjz010-nebula-manager merge-config \
                  ${settings.publicConfig} \
                  ${config.sops.secrets."${settingsSopsFile}".path} \
                  ${hostName} \
                  ${config.sops.secrets."${caSopsFile}".path} \
                  ${config.sops.secrets."${certSopsFile}".path} \
                  ${config.sops.secrets."${keySopsFile}".path} \
                  $NEBULA_CONFIG_OUTPUT
        '';
      };

    };
  defaultNetwork = makeNebulaService {
    netName = nebulaConfig.network_name;
    settings = {
      publicConfig = "${config.passthru.gjz010.secretRoot}/nebula/network.yaml";
      secretConfig = "${config.passthru.gjz010.secretRoot}/nebula/network_secrets.yaml.enc";
      certRoot = "${config.passthru.gjz010.secretRoot}/nebula/certs";
    };
  };
in
{
  options.gjz010.nebula = {
    enable = lib.mkOption {
      description = "Nebula network";
      default = lib.hasAttr config.gjz010.nebula.hostName nebulaConfig.nodes;
      type = lib.types.bool;
    };
    hostName = lib.mkOption {
      description = "Nebula hostname";
      default = config.networking.hostName;
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.gjz010.nebula.enable (
    lib.mkMerge [
      # Lighthouse setup and DNS.
      defaultNetwork
    ]
  );
}
