flake@{ inputs, self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (import ./yubikey.nix flake)
  ];
  options = {
    gjz010.options.keystone = {
      enable = lib.mkEnableOption "Enable my Keystone security chain.";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.gjz010.options.keystone.enable {
      gjz010.hardware.yubikey = {
        enable = true;
        autolock = {
          enable = true;
          productId = "1050/407/574";
        };
      };
      # Use GPG agent.
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      # Use pcscd for GPG.
      # Requires disable-ccid
      services.pcscd.enable = true;

      # Install kleopatra on preferred desktop
      environment.systemPackages =
        with pkgs;
        (lib.optionals config.gjz010.options.preferredDesktop.enable [
          kdePackages.kleopatra
          keepassxc
        ]);
    })
  ];
}
