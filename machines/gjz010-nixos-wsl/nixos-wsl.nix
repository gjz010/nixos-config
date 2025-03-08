# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:

{
  imports = [
    "${specialArgs.inputs.nixos-wsl}/modules"
  ];
  wsl.enable = true;
  wsl.defaultUser = "gjz010";

  # /bin/bash is good for WSL
  # https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673/10
  system.activationScripts.binbash = ''
    mkdir -m 0755 -p /bin
    ln -sfn /run/current-system/sw/bin/bash /bin/.bash.tmp
    mv /bin/.bash.tmp /bin/bash # atomically replace /usr/bin/env
  '';

  #nixpkgs.overlays = [
  #  (final: prev: {
  #    mesa = prev.mesa.override {
  #      galliumDrivers = [ "d3d12" "swrast" "i915" "lima" ];
  #    };
  #  })
  #];
  environment.enableDebugInfo = true;
  environment.systemPackages = [
    pkgs.mesa
    pkgs.gdb
  ];
  wsl.useWindowsDriver = true;
}
