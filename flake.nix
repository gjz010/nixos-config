{
  inputs = {
    secretsEmbedded = {
      url = "file+file:///dev/null";
      flake = false;
    };
    gitRevision = {
      url = "file+file:///dev/null";
      flake = false;
    };
    #nixpkgs.url = "path:/home/gjz010/nixpkgs";
    nixpkgs.url = "github:gjz010-Forks/nixpkgs/20250408";
    home-manager.url = "github:nix-community/home-manager";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
    disko = {
      url = "github:nix-community/disko";
    };
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nm2nix = {
      url = "github:Janik-Haag/nm2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-patcher = {
      url = "github:katrinafyi/nix-patcher";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      flake-parts,
      nixos-wsl,
      sops-nix,
      rust-overlay,
      nixos-anywhere,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.git-hooks-nix.flakeModule
        ./flakemodules/bundlers.nix
      ];
      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
            ];
            config = { };
          };
          pre-commit.check.enable = true;
          pre-commit.settings.hooks = {
            "sops-secrets-embedded-encrypt" = {
              enable = true;
              name = "sops-secrets-embedded";
              entry = "./scripts/secrets-embedded.ts --encrypt --nonew";
              pass_filenames = false;
            };
            nixfmt-rfc-style.enable = true;
            #rustfmt.enable = true;
            #clippy.enable = true;
            denofmt.enable = true;
            denolint.enable = true;
          };
          formatter = pkgs.nixfmt-tree;
          packages = pkgs.gjz010.packages;
          bundlers = pkgs.gjz010.bundlers;
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.treefmt2
              pkgs.nixfmt-rfc-style
              pkgs.nil
              pkgs.bashInteractive
              pkgs.sops
              pkgs.age
              pkgs.ssh-to-age
              nixos-anywhere.packages."${system}".nixos-anywhere
              pkgs.just
              pkgs.jq
              pkgs.yq-go
              pkgs.yq
              pkgs.deno
              inputs.nm2nix.packages."${system}".default
              pkgs.nebula
              inputs.nix-patcher.packages."${system}".nix-patcher
            ];
            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
            EDITOR = ./scripts/editor.sh;
          };
        };
      flake = {
        flakeModules = {
          bundler = ./flakemodules/bundlers.nix;
        };
        nixosConfigurations = import ./machines inputs;
        nixosModules = import ./modules { inherit self inputs; };
        overlays.single = import ./channel/overlay.nix { gjz010Flake = self; };
        overlays.default = nixpkgs.lib.composeExtensions rust-overlay.overlays.default self.overlays.single;
        templates = import ./channel/templates;
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };

}
