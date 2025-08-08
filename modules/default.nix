flake@{ inputs, self }:
rec {
  set-nix-path = import ./set-nix-path.nix flake;
  sops = import ./sops.nix flake;
  home-manager = import ./home-manager.nix flake;
  cachix = import ./cachix;
  nixpkgs-gjz010-overlay = import ./nixpkgs-gjz010-overlay.nix flake;
  nvidia = import ./nvidia.nix flake;
  auth-thu = import ./auth-thu.nix flake;
  nebula = import ./nebula flake;
  desktop = import ./desktop flake;
  udp2raw = import ./udp2raw flake;
  keystone = import ./keystone flake;
}
