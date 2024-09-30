flake{ inputs, self}:
{config, lib, pkgs, ...}:
let
makeNebulaService = {netName, settings}:
let
settingsSopsFile = "nebula-sops-${netName}.yaml";
netUserName = "nebula-sops-${netName}";
format = pkgs.formats.yaml {};
settingsSopsPath = config.sops.templates."${settingsSopsFile}".path;
generatedSettings = {
    networkId = netName;
    settings = lib.attrsets.recursiveUpdate {
        inherit (settings) pki;
        tun.dev = "nebula.${netName}";
        relay = {
            use_relays = true;
            relays 
        };
        listen = if settings.fixedPort then 4242 else 0;
    } settings.raw;
};
in
{
    sops.templates."${settingsSopsFile}" = {
        content = format.generate "${settingsSopsFile}" generatedSettings;
        owner = netUserName;
    };
    user.users."${netUserName}" = {
        group = netUserName;
        description = "Nebula service user for network ${netName}, with sops.";
        isSystemUser = true;
    };
    user.groups."${netUserName}" = {};
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
            ExecStartPre = "${nebula-config-merger}/bin/nebula-config-merger /tmp/nebula.config";
            ExecStart = "${pkgs.nebula}/bin/nebula -config /tmp/nebula.config";
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
    }
};
in
{
    options.gjz010.nebula = {
        enable = "Nebula network";

        lighthouse = {
            enable = lib.mkEnableOption "Node in Nebula network as lighthouse with publicly advertised DNS.";
        };
    };

    config = lib.mkIf options.gjz010.nebula.enable (lib.mkMerge [
        # Certificates.
        (lib.{

        })
        # Nebula the module, with sops support.

        # Lighthouse setup and DNS.
        (lib.mkIf config.gjz010.nebula.lighthouse.enable {

        })
    ])
}