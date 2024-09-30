flake@{ inputs, self}:
{config, lib, pkgs, ...}:
let
nebulaConfig = builtins.fromJSON (builtins.readFile ./network.json);
#isLightHouse = nebulaConfig."${config.networking.hostName}".lighthouse;
#isRelay = nebulaConfig."${config.networking.hostName}".relay;
makeNebulaService = {netName, settings}:
    let
    settingsSopsFile = "nebula-sops-${netName}.yaml";
    caSopsFile = "ca.crt";
    certSopsFile = "cert.crt";
    keySopsFile = "key.key";
    netUserName = "nebula-sops-${netName}";
    ddnsV4File = "nebula-cfddns-v4-${netName}";
    ddnsV6File = "nebula-cfddns-v6-${netName}";
    hostName = config.networking.hostName;
    ddnsLauncher = pkgs.writeShellScript "cfddns-launcher" ''
        export PATH=${pkgs.lib.makeBinPath [pkgs.yq pkgs.sops]}:$PATH
        domainRoot=$(sops -d ${config.sops.secrets."${settingsSopsFile}".path} | yq .data -r | yq ".\"nebula-secrets-global\".domainRoot")
        domainPart=$(sops -d secrets/nebula/network_secrets.yaml | yq .data -r | yq ".\"nebula-secrets-nodes\".\"${hostName}\".secretDomain")
        export CLOUDFLARE_API_TOKEN=$(sops -d secrets/nebula/network_secrets.yaml | yq .data -r | yq ".\"nebula-secrets-global\".\"cloudflare-dyndns-token\"")
        if [ "$1" = "v4" ] ; then
            export CLOUDFLARE_DOMAINS="$domainRoot.$domainPart"
            exec ${pkgs.cloudflare-dyndns}/bin/cloudflare-dyndns --cache-file $STATE_DIRECTORY/ip.cache -4 -no-6 --delete-missing
        fi
        if [ "$1" = "v6" ] ; then
            export CLOUDFLARE_DOMAINS="ipv6.$domainRoot.$domainPart"
            exec ${pkgs.cloudflare-dyndns}/bin/cloudflare-dyndns --cache-file $STATE_DIRECTORY/ip.cache -6 -no-4 --delete-missing
        fi
    '';
    in
    {
        sops.secrets."${settingsSopsFile}" = {
            format = "binary";
            sopsFile = settings.secretConfig;
        };
        sops.secrets."${caSopsFile}" = {
            format = "binary";
            sopsFile = "${settings.certRoot}/ca.crt";
        };
        sops.secrets."${certSopsFile}" = {
            format = "binary";
            sopsFile = "${settings.certRoot}/certs/${hostName}.crt";
        };
        sops.secrets."${keySopsFile}" = {
            format = "binary";
            sopsFile = "${settings.certRoot}/keys/${hostName}.key";
        };
        networking.firewall.allowedTCPPorts = [4242];
        users.users."${netUserName}" = {
            group = netUserName;
            description = "Nebula service user for network ${netName}, with sops.";
            isSystemUser = true;
        };
        users.groups."${netUserName}" = {};
        systemd.services."cloudflare-dyndns-ipv4@${netName}" = {
            description = "Nebula DNSv4 for ${netName}";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            startAt = "*:0/5";
            serviceConfig = {
                Type = "simple";
                DynamicUser = true;
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
                DynamicUser = true;
                StateDirectory = "cloudflare-dyndns-ipv6@${netName}";
                ExecStart = "${ddnsLauncher} v6";
            };
        };
        systemd.services."nebula-sops@${netName}" = {
            description = "Nebula VPN service (with sops) for ${netName}";
            wants = [ "basic.target" ];
            after = [ "basic.target" "network.target" ];
            before = [ "sshd.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                Type = "notify";
                Restart = "always";
                RuntimeDirectory = "nebula-sops/${netName}";
                RuntimeDirectoryMode = "0755";
                ExecStartPre = "${pkgs.gjz010.pkgs.gjz010-nebula-manager}/bin/gjz010-nebula-manager \
                ${settings.publicConfig} \
                ${config.sops.secrets."${settingsSopsFile}".path} \
                ${hostName} \
                ${config.sops.secrets."${caSopsFile}".path} \
                ${config.sops.secrets."${certSopsFile}".path} \
                ${config.sops.secrets."${keySopsFile}".path} \
                $RUNTIME_DIRECTORY/nebula.config";
                ExecStart = "${pkgs.nebula}/bin/nebula -config 	$RUNTIME_DIRECTORY/nebula.config";
                UMask = "0027";
                CapabilityBoundingSet = "CAP_NET_ADMIN";
                AmbientCapabilities = "CAP_NET_ADMIN";
                LockPersonality = true;
                NoNewPrivileges = true;
                PrivateDevices = false; # needs access to /dev/net/tun (below)
                DeviceAllow = "/dev/net/tun rw";
                DevicePolicy = "closed";
                PrivateTmp = true;
                PrivateUsers = false; # CapabilityBoundingSet needs to apply to the host namespace
                ProtectClock = true;
                ProtectControlGroups = true;
                ProtectHome = true;
                ProtectHostname = true;
                ProtectKernelLogs = true;
                ProtectKernelModules = true;
                ProtectKernelTunables = true;
                ProtectProc = "invisible";
                ProtectSystem = "strict";
                RestrictNamespaces = true;
                RestrictSUIDSGID = true;
                User = netUserName;
                Group = netUserName;
            };
            unitConfig.StartLimitIntervalSec = 0; # ensure Restart=always is always honoured (networks can go down for arbitrarily long)
        };
    };
defaultNetwork = makeNebulaService {
    netName = nebulaConfig.network_name;
    settings = {
        publicConfig = "${config.passthru.gjz010.secretRoot}/nebula/network.yaml";
        secretConfig = "${config.passthru.gjz010.secretRoot}/nebula/network_secrets.yaml";
        certRoot = "${config.passthru.gjz010.secretRoot}/nebula/certs";
    };
};
in
{
    options.gjz010.nebula = {
        enable = lib.mkOption{
            description = "Nebula network";
            default = lib.hasAttr config.networking.hostName nebulaConfig.nodes;
            type = lib.types.bool;
        };
    };

    config = lib.mkIf config.gjz010.nebula.enable (lib.mkMerge [
        # Lighthouse setup and DNS.
        defaultNetwork
    ]);
}
