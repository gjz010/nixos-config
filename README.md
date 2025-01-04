# gjz010's Nix channel & NixOS configuration

## Use packages

I've packaged a few software, free and proprietary.

```bash
# Run Icalingua++.
nix run github:gjz010/nix-channel#icalinguapp
# Run WeChat for UOS. ABSOLUTELY PROPRIETARY!
NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_INSECURE=1 nix run github:gjz010/nix-channel#wechat-uos --impure
# Run Wemeet. ABSOLUTELY PROPRIETARY!
NIXPKGS_ALLOW_UNFREE=1 nix run github:gjz010/nix-channel#wemeetapp --impure
```

## Use as Nixpkgs overlay

### Flake users

```nix
{
    description = "Some Nix Flake configuration, for example, the one for home-manager.";
    inputs.gjz010={
        url = "github:gjz010/nixos-config";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    outputs = { self, nixpkgs, gjz010 }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system; overlays = [ gjz010.overlays.default ]; };
        in {
            devShell.x86_64-linux = pkgs.mkShell {
                buildInputs = [ pkgs.gjz010.pkgs.icalinguapp ];
            };
        };
}
```

### Non-Flake users

```bash
nix-channel --add https://github.com/gjz010/nix-channel/archive/refs/heads/main.tar.gz gjz010
nix-channel --update gjz010
nix-build -E "let pkgs = import <nixpkgs> {overlays = [(import <gjz010>)];}; in pkgs.gjz010.pkgs.icalinguapp"
```

## Tar closure bundler

```bash
nix bundle --bundler github:gjz010/nix-channel#toTarball nixpkgs#hello
```

## Flake templates

Usage: `nix flake init -t github:gjz010/nix-channel#<TEMPLATE>`.

| Template                               | Description                                                                                                                         |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| dream2nix-nodejs-rollup-typescript-bin | Using dream2nix to package a binary built using rollup and Typescript.                                                              |
| nixos-with-flake                       | A NixOS configuration using Flake and home-manager. See [here](https://www.gjz010.com/articles/nixos-with-flake-init-tutorial.html) |
