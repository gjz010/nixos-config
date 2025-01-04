{
  config,
  lib,
  dream2nix,
  ...
}:
{
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  deps = { nixpkgs, ... }: { };

  name = "hello";
  version = "1.0.0";
  nodejs-package-lock-v3 = {
    packageLockFile = ./package-lock.json;
  };
  mkDerivation = {
    src = ./.;
  };
}
