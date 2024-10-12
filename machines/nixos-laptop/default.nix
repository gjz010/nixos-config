{ lib, specialArgs, ... }:
{
  nixpkgs.overlays = [ specialArgs.inputs.prismlauncher.overlays.default ];
  #nixpkgs.config.permittedInsecurePackages = [ "zotero-6.0.27" "electron-11.5.0" ];
  nixpkgs.config.allowUnfree = true;
  imports = [ ./configuration.nix
    ./tuxedo.nix
  #  ./nixpkgs-patches.nix
  ];
}
