flake@{ inputs, self }:
rec {
  set-nix-path = import ./set-nix-path.nix flake;
  sops = import ./sops.nix flake;
  home-manager = import ./home-manager.nix flake;
  cachix = import ./cachix;
}
