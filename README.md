My Nix channel
==============

A bunch of software, free and proprietary.


Run single application
--------------

```bash
# Run Icalingua++
nix run github:gjz010/nix-channel#icalinguapp
# Run WeChat for UOS
NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_INSECURE=1 nix run github:gjz010/nix-channel#wechat-uos --impure
# Run Wemeet
NIXPKGS_ALLOW_UNFREE=1 nix run github:gjz010/nix-channel#wemeetapp --impure
```

Use as Nixpkgs overlay
--------------

```nix
{
    description = "Some Nix Flake configuration, for example, the one for home-manager.";
    inputs.gjz010={
        url = "github:gjz010/nix-channel";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    outputs = { self, nixpkgs, gjz010 }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system; overlays = [ gjz010.overlays.default ]; config.allowUnfree=true;};
        in {
            devShell.x86_64-linux = pkgs.mkShell {
                buildInputs = [ pkgs.gjz010.pkgs.icalinguapp ];
            };
        };
}

```


Non-Flake users
--------------

```bash
nix-channel --add https://github.com/gjz010/nix-channel/archive/refs/heads/main.tar.gz gjz010
nix-channel --update gjz010
nix-build -E "let pkgs = import <nixpkgs> {overlays = [(import <gjz010>)];}; in pkgs.gjz010.pkgs.icalinguapp"
```


Utilities
--------------

### Tar closure bundler

TODO: integrate with nix-user-chroot and nix-bundle.

```bash
nix-build -E "let pkgs = import <nixpkgs> {overlays = [(import <gjz010>)];}; packClosure = pkgs.gjz010.lib.packClosure; in packClosure [pkgs.gcc]"
```