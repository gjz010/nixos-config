{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "gjz010-nebula-manager";
  version = "1.0.0";
  src = ./.;
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  RUSTC_BOOTSTRAP = true;
}
