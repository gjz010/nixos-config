{ pkgs, config, ... }:
{
  services.matrix-conduit = {
    enable = true;
    settings = {
      global = {
        address = "127.0.0.1";
        port = 6167;
        server_name = "matrix-bridge.gjz010.com";
        database_backend = "rocksdb";
        allow_registration = true;
        log = "trace";
      };
    };
    package = pkgs.matrix-conduit.overrideAttrs (
      final: prev: {
        patches = prev.patches ++ [ ./0001-UNSAFE-disable-authentication-for-conduit.patch ];
      }
    );
  };
  users = {
    users.conduit = {
      isSystemUser = true;
      group = "conduit";
    };
    groups.conduit = { };
  };
  systemd.services.conduit = {
    serviceConfig = {
      User = "conduit";
      Group = "conduit";
      BindPaths = [
        "/mnt/hdd-conduit-media/conduit-media/"
      ];
    };

  };
  virtualisation.oci-containers.containers = {
    mautrix-tg = {
      image = "ghcr.io/laikabridge/mautrix-telegram:v0.15.3-media";
      extraOptions = [ "--network=host" ];
      volumes = [ "/var/qqbridge/mautrix-tg:/data" ];
    };
    mautrix-discord = {
      image = "dock.mau.dev/mautrix/discord:v0.7.5";
      extraOptions = [ "--network=host" ];
      volumes = [ "/var/qqbridge/mautrix-discord:/data" ];
    };
  };
  services.redis.servers = {
    mautrix-tg = {
      enable = true;
      port = 6379;
      bind = "::1";
      requirePass = "yIvXgk0Vmth2mAHpSu5N0hYKihWMTBh0";
    };
  };
}
