{ config, pkgs, ... }:
{
  services.k3s = {
    enable = true;
    role = "server";

  };

}
