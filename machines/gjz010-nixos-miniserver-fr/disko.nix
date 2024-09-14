{ inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
  ];
}
