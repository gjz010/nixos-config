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
      };
    };
  };
  virtualisation.oci-containers.containers = {
    mautrix-tg = {
      image = "dock.mau.dev/mautrix/telegram:latest";
      extraOptions = [ "--network=host" ];
      volumes = [ "/var/qqbridge/mautrix-tg:/data" ];
    };
    mautrix-discord = {
      image = "dock.mau.dev/mautrix/discord:latest";
      extraOptions = [ "--network=host" ];
      volumes = [ "/var/qqbridge/mautrix-discord:/data" ];
    };
  };
}
