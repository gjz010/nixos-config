{ pkgsStatic, fetchFromGitHub }:
pkgsStatic.rustPlatform.buildRustPackage rec {
  pname = "nix-user-chroot";
  version = "1.2.2";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-user-chroot";
    sha256 = "8w2/Ncfcg6mMRFgMZg3CBBtAO/FI6G6hDMyaLCS3hwk=";
    rev = "1.2.2";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock"; # IFD here
  };
  doCheck = false;
}
  
