flake@{ inputs, self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    gjz010.hardware.yubikey = {
      enable = lib.mkEnableOption "Enable hardware Yubikey support.";
      autolock = {
        enable = lib.mkEnableOption "Enable lock-sessions on Yubikey unplug.";
        productId = lib.mkOption {
          type = lib.types.str;
          default = "1050/407/574";
          description = ''
            Product id.
            Obtained by `udevadm monitor --kernel --property --subsystem-match=usb`.
            https://bbs.archlinux.org/viewtopic.php?id=286711
          '';
        };
      };

    };
  };
  config = lib.mkIf config.gjz010.hardware.yubikey.enable (
    lib.mkMerge [
      {
        services.udev.packages = [
          pkgs.yubikey-personalization
          pkgs.libfido2
          pkgs.fuse
        ];
        programs.yubikey-touch-detector = {
          enable = true;
          verbose = true;
        };
        environment.systemPackages =
          with pkgs;
          (
            [
              yubikey-manager
              yubico-piv-tool
            ]
            ++ (lib.optionals config.gjz010.options.preferredDesktop.enable [
              yubioath-flutter
            ])
          );
      }
      (lib.mkIf config.gjz010.hardware.yubikey.autolock.enable {
        services.udev.extraRules = ''
          ACTION=="remove", ENV{PRODUCT}=="${config.gjz010.hardware.yubikey.autolock.productId}", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
        '';
      })
    ]
  );
}
