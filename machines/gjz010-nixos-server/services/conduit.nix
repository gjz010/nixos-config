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
      };
    };
  };
  virtualisation.oci-containers.containers = {
    mautrix-tg = {
      image = "ghcr.io/laikabridge/mautrix-telegram@sha256:8495e349d2c757a9ecd0bbda943c2d6e001cc055fc4538f6123be38c0708baef";
      extraOptions = [ "--network=host" ];
      volumes = [ "/var/qqbridge/mautrix-tg:/data" ];
    };
    mautrix-discord = {
      image = "dock.mau.dev/mautrix/discord:latest";
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
