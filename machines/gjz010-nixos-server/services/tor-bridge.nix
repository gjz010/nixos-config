{ pkgs, config, ... }:
{
  # This is a private tor bridge.
  # It can only be connected inside the LAN.

  services.tor = {
    enable = true;
    relay = {
      enable = true;
      role = "private-bridge";
    };
    settings = {
      ContactInfo = "toradmin@example.org";
      Nickname = "toradmin";
      ORPort = 9001;
      ControlPort = 9051;
    };
  };
}
