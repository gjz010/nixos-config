{ config, pkgs, ... }:
{
  services.redis.servers."matrix-qq-bridge-dev" = {
    enable = true;
    port = 6379;
  };
}
