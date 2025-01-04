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
      nix.settings.flake-registry = "";
      system.configurationRevision = self.dirtyRev or self.rev or (lib.strings.trim (builtins.readFile "${inputs.gitRevision}"));
      # Allow `nixos-rebuild` switch from an ssh session:
      # 1. Allow using ssh public key for sudo-authentication.
      # 2. Allow all wheel users (sudoers) to be trusted by nix-daemon.
      # TODO: will this affect behaviour of http proxy?
      security.pam = {
        sshAgentAuth.enable = true;
        services.sudo.sshAgentAuth = true;
      };
      programs.ssh.startAgent = true;
      nix.settings.trusted-users = [ "@wheel" ];
    };
}
