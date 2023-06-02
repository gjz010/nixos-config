{ pkgsStatic, rust, rust-bin, fetchFromGitHub, lib, makeRustPlatform }:
let
  target = rust.toRustTarget pkgsStatic.stdenv.targetPlatform;
  rustStatic = rust-bin.stable.latest.minimal.override {
    targets = [ target ];
  };
  rustPlatform = pkgsStatic.makeRustPlatform {
    cargo = rustStatic;
    rustc = rustStatic;
  };
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-user-chroot";
    sha256 = "8w2/Ncfcg6mMRFgMZg3CBBtAO/FI6G6hDMyaLCS3hwk=";
    rev = "1.2.2";
  };
in
rustPlatform.buildRustPackage {
  pname = "nix-user-chroot";
  version = "1.2.2";
  inherit src;
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  doCheck = false;
}
