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
}
