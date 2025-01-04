{
  rustPlatform,
  makeWrapper,
  lib,
  nebula,
  sops,
}:
rustPlatform.buildRustPackage rec {
  pname = "gjz010-nebula-manager";
  version = "1.0.0";
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  RUSTC_BOOTSTRAP = true;
  postFixup = ''
    wrapProgram $out/bin/gjz010-nebula-manager \
      --set PATH ${
        lib.makeBinPath [
          nebula
          sops
        ]
      }
  '';
}
