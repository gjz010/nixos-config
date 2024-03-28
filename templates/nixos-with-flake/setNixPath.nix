# Note: the self here refers to the NixOS flake!
{self, nixpkgs, ...}:
{
  nix.registry.nixpkgs.flake = nixpkgs;
  nix.registry.nixos-configuration.flake = self;
  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
  system.configurationRevision = self.rev or "dirty";
}
