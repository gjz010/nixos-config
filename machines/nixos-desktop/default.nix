{ lib, specialArgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "TencentMeeting_0300000000_3.15.0.402_x86_64_default.publish.deb"
    "TencentMeeting_0300000000_3.19.0.401_x86_64_default.publish.deb"
    "steam"
    "steam-original"
    "steam-run"
  ];
  imports = [ ./configuration.nix ];
}
