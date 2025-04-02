{ config, pkgs, ... }:
{
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
  };

}
