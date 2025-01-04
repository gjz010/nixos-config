{
  rustPlatform,
  xorg,
  pkgconfig,
  makeWrapper,
  patchelf,
  lib,
  libglvnd,
}:
rustPlatform.buildRustPackage rec {
  name = "egui-test";
  src = ./.;
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  buildInputs = [
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXext
  ];
  nativeBuildInputs = [
    pkgconfig
    makeWrapper
    patchelf
  ];
  postFixup = ''
    patchelf  $out/bin/egui-test --add-rpath $libPath
  '';
  libPath = lib.makeLibraryPath ([ libglvnd ]);
}
