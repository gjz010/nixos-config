flake@{ inputs, self, ... }:
{ lib, pkgs, config, ... }:
{
  options.gjz010.set-nix-path = {
    registryInputs = lib.mkOption
      {
        type = lib.types.listOf lib.types.str;
        default = [ "nixpkgs" ];
      };
  };
  config =
    let registryInputs = config.gjz010.set-nix-path.registryInputs;
    in
    {
      nix.registry = (builtins.listToAttrs (map
        (input: {
          name = input;
          value = {
            flake = inputs."${input}";
          };
        })
        registryInputs)) // {
        nixos-configuration.flake = self;
      };
      nix.nixPath = map (input: "${input}=${inputs."${input}"}") registryInputs;
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      system.configurationRevision = self.rev or self.dirtyRev or "dirty";
    };
}
